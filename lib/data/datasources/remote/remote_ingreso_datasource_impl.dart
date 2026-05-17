import 'package:dio/dio.dart';
import '/data/models/ingreso_model.dart';
import 'remote_ingreso_datasource.dart';

class RemoteIngresoDataSourceImpl implements RemoteIngresoDataSource {
  final Dio client;

  RemoteIngresoDataSourceImpl(this.client);

  @override
  Future<List<IngresoModel>> fetchIngresos(String usuarioId) async {
    final response = await client.get('/ingresos', queryParameters: {'usuario_id': usuarioId});
    final List<dynamic> data = response.data;
    return data.map((json) => IngresoModel.fromJson(json)).toList();
  }

  @override
  Future<void> createIngreso(IngresoModel ingreso) async {
    await client.post('/ingresos', data: ingreso.toJson());
  }

  @override
  Future<void> deleteIngreso(String id) async {
    await client.delete('/ingresos/$id');
  }
}