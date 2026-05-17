import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/di/injection_container.dart';
import '/domain/recomendacion/usecases/generar_recomendaciones.dart';
import '/domain/recomendacion/entities/recomendacion.dart';
import '/presentation/shared/base_view_model.dart';
import '/core/usecase.dart';

final recomendacionesViewModelProvider =
    StateNotifierProvider<RecomendacionesViewModel, BaseState<List<Recomendacion>>>(
  (ref) => RecomendacionesViewModel(sl<GenerarRecomendaciones>()),
);

class RecomendacionesViewModel extends BaseViewModel<List<Recomendacion>> {
  final GenerarRecomendaciones _useCase;
  RecomendacionesViewModel(this._useCase);

  Future<void> cargarRecomendaciones() async {
    emitLoading();
    final result = await _useCase(NoParams());
    result.fold(
      (failure) => emitError(failure.message),
      (data) => emitData(data),
    );
  }
}