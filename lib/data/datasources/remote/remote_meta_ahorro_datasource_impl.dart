import 'package:dio/dio.dart';
import '/data/models/meta_ahorro_model.dart';
import 'remote_meta_ahorro_datasource.dart';

class RemoteMetaAhorroDataSourceImpl implements RemoteMetaAhorroDataSource {
  final Dio client;
  RemoteMetaAhorroDataSourceImpl(this.client);

  @override
  Future<List<MetaAhorroModel>> fetchMetas(String usuarioId) async {
    final response = await client.get('/metas', queryParameters: {'usuario_id': usuarioId});
    final List data = response.data;
    return data.map((json) => MetaAhorroModel.fromJson(json)).toList();
  }

  @override
  Future<void> createMeta(MetaAhorroModel meta) async {
    await client.post('/metas', data: meta.toJson());
  }

  @override
  Future<void> deleteMeta(String id) async {
    await client.delete('/metas/$id');
  }
}