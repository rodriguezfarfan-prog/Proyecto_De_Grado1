import '/data/models/usuario_model.dart';

abstract class AuthRemoteDataSource {
  Future<UsuarioModel> login(String email, String password);
  Future<UsuarioModel> registro(String nombre, String email, String password);
}
