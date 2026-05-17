import '/data/models/usuario_model.dart';

abstract class RemoteUsuarioDataSource {
  Future<UsuarioModel> fetchUsuarioActual();
}