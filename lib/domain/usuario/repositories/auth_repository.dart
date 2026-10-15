import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '../entities/usuario.dart';

abstract class AuthRepository {
  Future<Either<Failure, Usuario>> login(String email, String password);
  Future<Either<Failure, Usuario>> registro(
    String nombre,
    String email,
    String password,
  );
  Future<void> logout();
  Future<String?> obtenerUserId();
}
