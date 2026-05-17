import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/di/injection_container.dart';
import '/domain/diagnostico/usecases/realizar_diagnostico.dart';
import '/domain/simulacion/usecases/simular_optimizacion.dart';
import '/domain/diagnostico/entities/diagnostico_resultado.dart';
import '/domain/simulacion/entities/comparativa_gastos.dart';
import '/presentation/shared/base_view_model.dart';
import '/core/usecase.dart';

class DashboardData {
  final DiagnosticoResultado diagnostico;
  final ComparativaGastos simulacion;
  DashboardData({required this.diagnostico, required this.simulacion});
}

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, BaseState<DashboardData>>(
  (ref) => DashboardViewModel(sl<RealizarDiagnostico>(), sl<SimularOptimizacion>()),
);

class DashboardViewModel extends BaseViewModel<DashboardData> {
  final RealizarDiagnostico _diagnostico;
  final SimularOptimizacion _simulacion;
  DashboardViewModel(this._diagnostico, this._simulacion);

  Future<void> cargarDashboard() async {
    emitLoading();
    final diag = await _diagnostico(NoParams());
    final sim = await _simulacion(NoParams());

    diag.fold(
      (l) => emitError(l.message),
      (d) => sim.fold(
        (l) => emitError(l.message),
        (s) => emitData(DashboardData(diagnostico: d, simulacion: s)),
      ),
    );
  }
}