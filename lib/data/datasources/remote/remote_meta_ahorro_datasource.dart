import '/data/models/meta_ahorro_model.dart';

abstract class RemoteMetaAhorroDataSource {
  Future<List<MetaAhorroModel>> fetchMetas(String usuarioId);
  Future<void> createMeta(MetaAhorroModel meta);
  Future<void> deleteMeta(String id);
}