import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/di/injection_container.dart';
import '/domain/diagnostico/usecases/realizar_diagnostico.dart';
import '/domain/diagnostico/entities/diagnostico_resultado.dart';
import '/presentation/shared/base_view_model.dart';
import '/core/usecase.dart';

final diagnosticoViewModelProvider =
    StateNotifierProvider<DiagnosticoViewModel, BaseState<DiagnosticoResultado>>(
      (ref) => DiagnosticoViewModel(sl<RealizarDiagnostico>()),
    );

class DiagnosticoViewModel extends BaseViewModel<DiagnosticoResultado> {
  final RealizarDiagnostico _useCase;
  DiagnosticoViewModel(this._useCase);

  Future<void> cargarDiagnostico() async {
    emitLoading();
    final result = await _useCase(NoParams());
    result.fold(
      (failure) => emitError(failure.message),
      (data) => emitData(data),
    );
  }
}