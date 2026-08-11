import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/di/injection_container.dart';
import '/domain/diagnostico/usecases/realizar_diagnostico.dart';
import '/domain/simulacion/usecases/simular_optimizacion.dart';
import '/domain/diagnostico/entities/diagnostico_resultado.dart';
import '/domain/simulacion/entities/comparativa_gastos.dart';
import '/presentation/shared/base_view_model.dart';
import '/core/usecase.dart';

class DiagnosticoCompleto {
  final DiagnosticoResultado diagnostico;
  final ComparativaGastos? comparativa; // Puede ser null si aún no se ha cargado

  DiagnosticoCompleto({required this.diagnostico, this.comparativa});
}

final diagnosticoViewModelProvider =
    StateNotifierProvider<DiagnosticoViewModel, BaseState<DiagnosticoCompleto>>(
  (ref) => DiagnosticoViewModel(sl<RealizarDiagnostico>(), sl<SimularOptimizacion>()),
);

class DiagnosticoViewModel extends BaseViewModel<DiagnosticoCompleto> {
  final RealizarDiagnostico _realizarDiagnostico;
  final SimularOptimizacion _simularOptimizacion;

  DiagnosticoViewModel(this._realizarDiagnostico, this._simularOptimizacion);

  Future<void> cargarDiagnostico() async {
    emitLoading();
    // Ejecutar ambos casos de uso en paralelo
    final diagResult = await _realizarDiagnostico(NoParams());
    final simResult = await _simularOptimizacion(NoParams());

    diagResult.fold(
      (failure) => emitError(failure.message),
      (diagnostico) => simResult.fold(
        (failure) => emitError(failure.message),
        (comparativa) => emitData(DiagnosticoCompleto(
          diagnostico: diagnostico,
          comparativa: comparativa,
        )),
      ),
    );
  }
}