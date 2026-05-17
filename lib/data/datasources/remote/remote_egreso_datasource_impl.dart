import 'package:dio/dio.dart';
import '/data/models/egreso_model.dart';
import 'remote_egreso_datasource.dart';

class RemoteEgresoDataSourceImpl implements RemoteEgresoDataSource {
  final Dio client;

  RemoteEgresoDataSourceImpl(this.client);

  @override
  Future<List<EgresoModel>> fetchEgresos(String usuarioId) async {
    final response = await client.get('/egresos', queryParameters: {'usuario_id': usuarioId});
    final List<dynamic> data = response.data;
    return data.map((json) => EgresoModel.fromJson(json)).toList();
  }

  @override
  Future<void> createEgreso(EgresoModel egreso) async {
    await client.post('/egresos', data: egreso.toJson());
  }

  @override
  Future<void> deleteEgreso(String id) async {
    await client.delete('/egresos/$id');
  }
}