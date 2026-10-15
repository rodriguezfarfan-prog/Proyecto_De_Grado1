import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/di/injection_container.dart';
import '/domain/usuario/usecases/login_usuario.dart';
import '/domain/usuario/usecases/registrar_usuario.dart';
import '/domain/usuario/entities/usuario.dart';
import '/presentation/shared/base_view_model.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, BaseState<Usuario>>(
      (ref) => AuthViewModel(sl<LoginUsuario>(), sl<RegistrarUsuario>()),
    );

class AuthViewModel extends BaseViewModel<Usuario> {
  final LoginUsuario _login;
  final RegistrarUsuario _registrar;

  AuthViewModel(this._login, this._registrar);

  Future<void> iniciarSesion(String email, String password) async {
    emitLoading();
    final result = await _login(LoginParams(email: email, password: password));
    result.fold(
      (failure) => emitError(failure.message),
      (usuario) => emitData(usuario),
    );
  }

  Future<void> registrarse(String nombre, String email, String password) async {
    emitLoading();
    final result = await _registrar(
      RegistrarParams(nombre: nombre, email: email, password: password),
    );
    result.fold(
      (failure) => emitError(failure.message),
      (usuario) => emitData(usuario),
    );
  }
}
