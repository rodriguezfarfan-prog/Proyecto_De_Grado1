import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_up_project/di/injection_container.dart';
import 'package:fin_up_project/domain/ahorro/entities/ahorro_resumen.dart';
import 'package:fin_up_project/domain/ahorro/repositories/meta_ahorro_repository.dart';
import 'package:fin_up_project/domain/ahorro/usecases/eliminar_meta_ahorro.dart';
import 'package:fin_up_project/domain/ahorro/usecases/agregar_abono_meta.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/ingreso_repository.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';

final ahorroViewModelProvider =
    StateNotifierProvider<AhorroViewModel, BaseState<AhorroResumen>>(
      (ref) => AhorroViewModel(
        sl<MetaAhorroRepository>(),
        sl<EliminarMetaAhorro>(),
        sl<AgregarAbonoMeta>(),
        sl<IngresoRepository>(),
      ),
    );

class AhorroViewModel extends BaseViewModel<AhorroResumen> {
  final MetaAhorroRepository _metaRepo;
  final EliminarMetaAhorro _eliminarMeta;
  final AgregarAbonoMeta _agregarAbono;
  final IngresoRepository _ingresoRepo;

  AhorroViewModel(
    this._metaRepo,
    this._eliminarMeta,
    this._agregarAbono,
    this._ingresoRepo,
  );

  Future<void> cargarMetas() async {
    emitLoading();
    final result = await _metaRepo.obtenerMetas();
    result.fold((failure) => emitError(failure.message), (metas) {
      final total = metas.fold<double>(
        0.0,
        (sum, meta) => sum + meta.montoActual.valor,
      );
      emitData(AhorroResumen(metas: metas, totalAhorrado: total));
    });
  }

  Future<void> eliminarMeta(String id) async {
    emitLoading();
    final result = await _eliminarMeta(EliminarMetaParams(id));
    result.fold((failure) => emitError(failure.message), (_) => cargarMetas());
  }

  /// Retorna null si el abono fue exitoso, o un mensaje de error si no se pudo hacer.
  Future<String?> agregarAbono(String id, double monto) async {
    // Validar contra la capacidad de ahorro
    final ingresosEither = await _ingresoRepo.obtenerIngresos();

    if (ingresosEither.isLeft()) {
      return 'No se pudieron obtener tus ingresos para validar el abono.';
    }

    final ingresos = ingresosEither.fold((_) => <dynamic>[], (list) => list);
    final totalIngresos = ingresos.fold<double>(
      0.0,
      (sum, i) => sum + i.monto.valor,
    );

    emitLoading();
    final result = await _agregarAbono(
      AgregarAbonoParams(id: id, monto: monto),
    );

    return result.fold((failure) => failure.message, (_) {
      cargarMetas();
      return null;
    });
  }
}
