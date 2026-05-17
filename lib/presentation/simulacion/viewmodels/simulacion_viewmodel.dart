import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/di/injection_container.dart';
import '/domain/simulacion/usecases/simular_optimizacion.dart';
import '/domain/simulacion/entities/comparativa_gastos.dart';
import '/presentation/shared/base_view_model.dart';
import '/core/usecase.dart';

final simulacionViewModelProvider =
    StateNotifierProvider<SimulacionViewModel, BaseState<ComparativaGastos>>(
  (ref) => SimulacionViewModel(sl<SimularOptimizacion>()),
);

class SimulacionViewModel extends BaseViewModel<ComparativaGastos> {
  final SimularOptimizacion _useCase;
  SimulacionViewModel(this._useCase);

  Future<void> cargarSimulacion() async {
    emitLoading();
    final result = await _useCase(NoParams());
    result.fold(
      (failure) => emitError(failure.message),
      (data) => emitData(data),
    );
  }
}