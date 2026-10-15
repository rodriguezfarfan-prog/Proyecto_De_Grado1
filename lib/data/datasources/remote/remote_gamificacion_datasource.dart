abstract class RemoteGamificacionDataSource {
  Future<Map<String, dynamic>> fetchPerfil(String usuarioId);
  Future<int> sumarPuntos(String usuarioId, int puntos);
  Future<Map<String, dynamic>> desbloquearLogro(
    String usuarioId,
    String logroId,
    int puntos,
  );
  Future<Map<String, dynamic>> registrarAccion(
    String usuarioId,
    String tipoAccion,
  );
  Future<Map<String, dynamic>> registrarRacha(String usuarioId);
}
