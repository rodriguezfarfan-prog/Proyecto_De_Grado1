import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_up_project/di/injection_container.dart';
import 'package:fin_up_project/domain/diagnostico/usecases/realizar_diagnostico.dart';
import 'package:fin_up_project/domain/diagnostico/usecases/obtener_periodo_anterior.dart';
import 'package:fin_up_project/domain/diagnostico/entities/diagnostico_resultado.dart';
import 'package:fin_up_project/domain/diagnostico/entities/periodo_financiero.dart';
import 'package:fin_up_project/domain/diagnostico/entities/egreso.dart';
import 'package:fin_up_project/domain/diagnostico/entities/ingreso.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/egreso_repository.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/ingreso_repository.dart';
import 'package:fin_up_project/core/services/config_service.dart';
import 'package:fin_up_project/core/utils/calculadora_periodos.dart';
import 'package:fin_up_project/core/usecase.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';

class MovimientosData {
  final DiagnosticoResultado diagnosticoActual;
  final String nombreMesActual;
  final DateTime inicioActual;
  final DateTime finActual;
  final PeriodoFinanciero? periodoAnterior;
  final List<Ingreso> ingresosActuales;
  final List<Egreso> egresosActuales;

  MovimientosData({
    required this.diagnosticoActual,
    required this.nombreMesActual,
    required this.inicioActual,
    required this.finActual,
    required this.periodoAnterior,
    required this.ingresosActuales,
    required this.egresosActuales,
  });
}

final diagnosticoViewModelProvider =
    StateNotifierProvider<DiagnosticoViewModel, BaseState<MovimientosData>>(
      (ref) => DiagnosticoViewModel(
        sl<RealizarDiagnostico>(),
        sl<ObtenerPeriodoAnterior>(),
        sl<IngresoRepository>(),
        sl<EgresoRepository>(),
      ),
    );

class DiagnosticoViewModel extends BaseViewModel<MovimientosData> {
  final RealizarDiagnostico _realizar;
  final ObtenerPeriodoAnterior _anterior;
  final IngresoRepository _ingresoRepo;
  final EgresoRepository _egresoRepo;

  DiagnosticoViewModel(
    this._realizar,
    this._anterior,
    this._ingresoRepo,
    this._egresoRepo,
  );

  Future<void> cargarTodo() async {
    emitLoading();
    final diaInicio = await ConfigService.obtenerDiaInicio();
    final hoy = DateTime.now();
    final rangoActual = CalculadoraPeriodos.rangoDeFecha(hoy, diaInicio);

    final diagResult = await _realizar(NoParams());
    final anteriorResult = await _anterior(
      ObtenerPeriodoAnteriorParams(diaInicio: diaInicio),
    );

    if (diagResult.isLeft()) {
      diagResult.fold((f) => emitError(f.message), (_) {});
      return;
    }

    final diag = diagResult.fold((_) => throw Exception(), (d) => d);
    final periodoAnterior = anteriorResult.fold((_) => null, (p) => p);

    // ✅ CORREGIDO: desenvolver el Either antes de usar la lista
    final ingresosEither = await _ingresoRepo.obtenerIngresos();
    final egresosEither = await _egresoRepo.obtenerEgresos();

    final ingresos = ingresosEither.getOrElse(() => <Ingreso>[]);
    final egresos = egresosEither.getOrElse(() => <Egreso>[]);

    final ingresosActuales = ingresos
        .where(
          (x) =>
              !x.fecha.fecha.isBefore(rangoActual.inicio) &&
              !x.fecha.fecha.isAfter(rangoActual.fin),
        )
        .toList();
    final egresosActuales = egresos
        .where(
          (x) =>
              !x.fecha.fecha.isBefore(rangoActual.inicio) &&
              !x.fecha.fecha.isAfter(rangoActual.fin),
        )
        .toList();

    emitData(
      MovimientosData(
        diagnosticoActual: diag,
        nombreMesActual: CalculadoraPeriodos.nombreMes(rangoActual.inicio),
        inicioActual: rangoActual.inicio,
        finActual: rangoActual.fin,
        periodoAnterior: periodoAnterior,
        ingresosActuales: ingresosActuales,
        egresosActuales: egresosActuales,
      ),
    );
  }

  Future<String?> agregarIngreso(Ingreso ingreso) async {
    final result = await _ingresoRepo.guardarIngreso(ingreso);
    return result.fold((f) => f.message, (_) {
      cargarTodo();
      return null;
    });
  }

  Future<String?> actualizarIngreso(Ingreso ingreso) async {
    final result = await _ingresoRepo.actualizarIngreso(ingreso);
    return result.fold((f) => f.message, (_) {
      cargarTodo();
      return null;
    });
  }

  Future<String?> eliminarIngreso(String id) async {
    final result = await _ingresoRepo.eliminarIngreso(id);
    return result.fold((f) => f.message, (_) {
      cargarTodo();
      return null;
    });
  }

  Future<String?> agregarEgreso(Egreso egreso) async {
    final result = await _egresoRepo.guardarEgreso(egreso);
    return result.fold((f) => f.message, (_) {
      cargarTodo();
      return null;
    });
  }

  Future<String?> actualizarEgreso(Egreso egreso) async {
    final result = await _egresoRepo.actualizarEgreso(egreso);
    return result.fold((f) => f.message, (_) {
      cargarTodo();
      return null;
    });
  }

  Future<String?> eliminarEgreso(String id) async {
    final result = await _egresoRepo.eliminarEgreso(id);
    return result.fold((f) => f.message, (_) {
      cargarTodo();
      return null;
    });
  }
}
