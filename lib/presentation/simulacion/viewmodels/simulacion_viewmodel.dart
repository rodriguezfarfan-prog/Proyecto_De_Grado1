import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/di/injection_container.dart';
import '/domain/simulacion_compra/usecases/simular_compra.dart';
import '/domain/simulacion_compra/entities/datos_compra.dart';
import '/domain/simulacion_compra/entities/resultado_simulacion.dart';
import '/presentation/shared/base_view_model.dart';

final simulacionCompraViewModelProvider =
    StateNotifierProvider<SimulacionCompraViewModel, BaseState<ResultadoSimulacion>>(
  (ref) => SimulacionCompraViewModel(sl<SimularCompra>()),
);

class SimulacionCompraViewModel extends BaseViewModel<ResultadoSimulacion> {
  final SimularCompra _simularCompra;
  SimulacionCompraViewModel(this._simularCompra);

  Future<void> calcular(DatosCompra datos) async {
    emitLoading();
    final result = await _simularCompra(datos);
    result.fold(
      (failure) => emitError(failure.message),
      (res) => emitData(res),
    );
  }
}