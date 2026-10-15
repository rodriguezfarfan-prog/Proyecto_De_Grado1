import 'package:fin_up_project/data/models/ingreso_model.dart';

abstract class RemoteIngresoDataSource {
  Future<List<IngresoModel>> fetchIngresos(String usuarioId);
  Future<void> createIngreso(IngresoModel ingreso);
  Future<void> updateIngreso(IngresoModel ingreso);
  Future<void> deleteIngreso(String id);
}
