import '/data/models/ingreso_model.dart';

abstract class RemoteIngresoDataSource {
  Future<List<IngresoModel>> fetchIngresos(String usuarioId);
  Future<void> createIngreso(IngresoModel ingreso);
  Future<void> deleteIngreso(String id);
}