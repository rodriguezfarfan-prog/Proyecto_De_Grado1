import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/di/injection_container.dart';
import '/domain/ahorro/usecases/planificar_ahorro.dart';
import '/domain/ahorro/entities/plan_ahorro.dart';
import '/presentation/shared/base_view_model.dart';

final ahorroViewModelProvider =
    StateNotifierProvider<AhorroViewModel, BaseState<PlanAhorro>>(
  (ref) => AhorroViewModel(sl<PlanificarAhorro>()),
);

class AhorroViewModel extends BaseViewModel<PlanAhorro> {
  final PlanificarAhorro _useCase;
  AhorroViewModel(this._useCase);

  Future<void> calcularPlan(String metaId) async {
    emitLoading();
    final result = await _useCase(PlanificarAhorroParams(metaId: metaId));
    result.fold(
      (failure) => emitError(failure.message),
      (plan) => emitData(plan),
    );
  }
}