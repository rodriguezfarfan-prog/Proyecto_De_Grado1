import 'package:dio/dio.dart';
import '/data/models/usuario_model.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UsuarioModel> login(String email, String password) async {
    final response = await client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return UsuarioModel.fromJson(response.data);
  }

  @override
  Future<UsuarioModel> registro(
    String nombre,
    String email,
    String password,
  ) async {
    final response = await client.post(
      '/auth/registro',
      data: {'nombre': nombre, 'email': email, 'password': password},
    );
    return UsuarioModel.fromJson(response.data);
  }
}
