import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/ahorro/entities/plan_ahorro.dart';
import '/domain/ahorro/repositories/meta_ahorro_repository.dart';
import '/domain/diagnostico/repositories/ingreso_repository.dart';

class PlanificarAhorroParams {
  final String metaId;
  PlanificarAhorroParams({required this.metaId});
}

class PlanificarAhorro extends UseCase<PlanAhorro, PlanificarAhorroParams> {
  final MetaAhorroRepository metaRepo;
  final IngresoRepository ingresoRepo;

  PlanificarAhorro(this.metaRepo, this.ingresoRepo);

  @override
  Future<Either<Failure, PlanAhorro>> call(PlanificarAhorroParams params) async {
    final metaEither = await metaRepo.obtenerMetas();
    final ingresoEither = await ingresoRepo.obtenerIngresos();

    return metaEither.fold(
      (l) => Left(l),
      (metas) {
        final meta = metas.firstWhere((m) => m.id == params.metaId);
        return ingresoEither.fold(
          (l) => Left(l),
          (ingresos) {
            final ingresoMensual = ingresos.fold<double>(0.0, (sum, i) => sum + i.monto.valor);
            final mesesRestantes = meta.fechaLimite.difference(DateTime.now()).inDays ~/ 30;
            final montoFaltante = meta.montoObjetivo.valor - meta.montoActual.valor;
            final montoMensual = montoFaltante / mesesRestantes.clamp(1, 9999).toDouble();
            final porcentaje = (montoMensual / ingresoMensual * 100).clamp(0.0, 100.0);
            return Right(PlanAhorro(
              montoMensualRequerido: montoMensual,
              mesesRestantes: mesesRestantes,
              porcentajeIngreso: porcentaje,
            ));
          },
        );
      },
    );
  }
}