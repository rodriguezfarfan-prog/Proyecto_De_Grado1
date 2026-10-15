import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import '../entities/perfil_gamificacion.dart';
import '../entities/logro.dart';

abstract class GamificacionRepository {
  Future<Either<Failure, PerfilGamificacion>> obtenerPerfil();
  Future<Either<Failure, int>> sumarPuntos(int puntos);

  /// Retorna `true` si el logro es nuevo (para mostrar popup).
  Future<Either<Failure, bool>> desbloquearLogro(Logro logro);
  Future<Either<Failure, int>> registrarAccion(String tipoAccion);
  Future<Either<Failure, Map<String, dynamic>>> registrarRacha();
}
