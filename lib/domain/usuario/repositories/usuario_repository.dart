import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '../entities/usuario.dart';

abstract class UsuarioRepository {
  Future<Either<Failure, Usuario>> obtenerUsuarioActual();
}