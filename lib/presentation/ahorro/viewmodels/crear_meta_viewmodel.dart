import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_up_project/di/injection_container.dart';
import 'package:fin_up_project/domain/ahorro/usecases/crear_meta_ahorro.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';
import 'package:dartz/dartz.dart';

final crearMetaViewModelProvider =
    StateNotifierProvider<CrearMetaViewModel, BaseState<Unit>>(
      (ref) => CrearMetaViewModel(sl<CrearMetaAhorro>()),
    );

class CrearMetaViewModel extends BaseViewModel<Unit> {
  final CrearMetaAhorro _crearMetaAhorro;
  CrearMetaViewModel(this._crearMetaAhorro);

  Future<void> guardar({
    required String nombre,
    required double montoObjetivo,
    required double montoActual,
    required int meses,
    String? descripcion,
  }) async {
    emitLoading();
    final params = CrearMetaAhorroParams(
      nombre: nombre,
      montoObjetivo: montoObjetivo,
      montoActual: montoActual,
      meses: meses,
      descripcion: descripcion,
    );
    final result = await _crearMetaAhorro(params);
    result.fold(
      (failure) => emitError(failure.message),
      (unit) => emitData(unit),
    );
  }
}
