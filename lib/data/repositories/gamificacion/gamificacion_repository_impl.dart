import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/data/datasources/remote/remote_gamificacion_datasource.dart';
import 'package:fin_up_project/domain/gamificacion/entities/logro.dart';
import 'package:fin_up_project/domain/gamificacion/entities/perfil_gamificacion.dart';
import 'package:fin_up_project/domain/gamificacion/repositories/gamificacion_repository.dart';
import 'package:fin_up_project/domain/usuario/repositories/auth_repository.dart';

class GamificacionRepositoryImpl implements GamificacionRepository {
  final RemoteGamificacionDataSource remote;
  final AuthRepository authRepo;

  GamificacionRepositoryImpl(this.remote, this.authRepo);

  @override
  Future<Either<Failure, PerfilGamificacion>> obtenerPerfil() async {
    try {
      final userId = await authRepo.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final data = await remote.fetchPerfil(userId);
      final user = data['usuario'] as Map<String, dynamic>;
      final logros = (data['logros'] as List)
          .map((l) => l['logro_id'] as String)
          .toList();

      return Right(
        PerfilGamificacion(
          usuarioId: user['id'],
          nombre: user['nombre'],
          puntos: user['puntos'] ?? 0,
          logrosDesbloqueados: logros,
          rachaActual: user['racha_actual'] ?? 0,
          ultimaVisita: user['ultima_visita'] != null
              ? DateTime.parse(user['ultima_visita'].toString())
              : null,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Error al obtener perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> sumarPuntos(int puntos) async {
    try {
      final userId = await authRepo.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final total = await remote.sumarPuntos(userId, puntos);
      return Right(total);
    } catch (e) {
      return Left(ServerFailure('Error al sumar puntos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> desbloquearLogro(Logro logro) async {
    try {
      final userId = await authRepo.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final data = await remote.desbloquearLogro(
        userId,
        logro.id,
        logro.puntos,
      );
      return Right(data['nuevo'] == true);
    } catch (e) {
      return Left(ServerFailure('Error al desbloquear logro: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> registrarAccion(String tipoAccion) async {
    try {
      final userId = await authRepo.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final data = await remote.registrarAccion(userId, tipoAccion);
      final otorgados = data['puntosOtorgados'] ?? 0;
      return Right(otorgados);
    } catch (e) {
      return Left(ServerFailure('Error al registrar acción: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> registrarRacha() async {
    try {
      final userId = await authRepo.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final data = await remote.registrarRacha(userId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Error al registrar racha: $e'));
    }
  }
}
