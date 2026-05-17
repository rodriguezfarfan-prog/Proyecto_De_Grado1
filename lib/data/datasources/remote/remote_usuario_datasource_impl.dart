import 'package:dio/dio.dart';
import '/data/models/usuario_model.dart';
import 'remote_usuario_datasource.dart';

class RemoteUsuarioDataSourceImpl implements RemoteUsuarioDataSource {
  final Dio client;

  RemoteUsuarioDataSourceImpl(this.client);

  @override
  Future<UsuarioModel> fetchUsuarioActual() async {
    // En un entorno real, el backend devuelve el usuario autenticado.
    // Por ahora, usamos un endpoint genérico con un ID fijo (mock).
    const userId = 'USER_UUID_DE_PRUEBA'; // Debe coincidir con la BD
    final response = await client.get('/usuarios/$userId');
    return UsuarioModel.fromJson(response.data);
  }
}