import 'package:dio/dio.dart';
import 'remote_gamificacion_datasource.dart';

class RemoteGamificacionDataSourceImpl implements RemoteGamificacionDataSource {
  final Dio client;
  RemoteGamificacionDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> fetchPerfil(String usuarioId) async {
    final response = await client.get(
      '/gamificacion/perfil',
      queryParameters: {'usuario_id': usuarioId},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<int> sumarPuntos(String usuarioId, int puntos) async {
    final response = await client.post(
      '/gamificacion/puntos',
      data: {'usuario_id': usuarioId, 'puntos': puntos},
    );
    return response.data['puntos'] as int;
  }

  @override
  Future<Map<String, dynamic>> desbloquearLogro(
    String usuarioId,
    String logroId,
    int puntos,
  ) async {
    final response = await client.post(
      '/gamificacion/logro',
      data: {'usuario_id': usuarioId, 'logro_id': logroId, 'puntos': puntos},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> registrarAccion(
    String usuarioId,
    String tipoAccion,
  ) async {
    final response = await client.post(
      '/gamificacion/accion',
      data: {'usuario_id': usuarioId, 'tipo_accion': tipoAccion},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> registrarRacha(String usuarioId) async {
    final response = await client.post(
      '/gamificacion/racha',
      data: {'usuario_id': usuarioId},
    );
    return response.data as Map<String, dynamic>;
  }
}
