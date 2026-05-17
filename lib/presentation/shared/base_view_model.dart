import 'package:flutter_riverpod/flutter_riverpod.dart';

// ──────────────────────────────────────────────
// ViewModel base
// ──────────────────────────────────────────────
abstract class BaseViewModel<T> extends StateNotifier<BaseState<T>> {
  BaseViewModel() : super(BaseState<T>.initial());

  void emitLoading() => state = BaseState<T>.loading();
  void emitData(T data) => state = BaseState<T>.data(data);
  void emitError(String message) => state = BaseState<T>.error(message);
}

// ──────────────────────────────────────────────
// Estados sellados
// ──────────────────────────────────────────────
sealed class BaseState<T> {
  const BaseState._(); // constructor privado para evitar instancias externas

  const factory BaseState.initial() = Initial<T>;
  const factory BaseState.loading() = Loading<T>;
  const factory BaseState.data(T value) = Data<T>;
  const factory BaseState.error(String message) = Error<T>;
}

class Initial<T> extends BaseState<T> {
  const Initial() : super._();
}

class Loading<T> extends BaseState<T> {
  const Loading() : super._();
}

class Data<T> extends BaseState<T> {
  final T value;
  const Data(this.value) : super._();
}

class Error<T> extends BaseState<T> {
  final String message;
  const Error(this.message) : super._();
}

// ──────────────────────────────────────────────
// Extensión para usar .when() en las vistas
// ──────────────────────────────────────────────
extension BaseStateWhen<T> on BaseState<T> {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T value) data,
    required R Function(String message) error,
  }) {
    if (this is Initial) return initial();
    if (this is Loading) return loading();
    if (this is Data) return data((this as Data<T>).value);
    if (this is Error) return error((this as Error<T>).message);
    throw Exception('Estado desconocido');
  }
}