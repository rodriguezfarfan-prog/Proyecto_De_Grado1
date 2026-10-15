import 'package:fin_up_project/data/models/egreso_model.dart';

abstract class RemoteEgresoDataSource {
  Future<List<EgresoModel>> fetchEgresos(String usuarioId);
  Future<void> createEgreso(EgresoModel egreso);
  Future<void> updateEgreso(EgresoModel egreso);
  Future<void> deleteEgreso(String id);
}
