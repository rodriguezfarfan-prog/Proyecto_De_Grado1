import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/recomendacion/entities/recomendacion.dart';
import '/domain/diagnostico/repositories/egreso_repository.dart';
import '/domain/diagnostico/entities/egreso.dart';

class GenerarRecomendaciones extends UseCase<List<Recomendacion>, NoParams> {
  final EgresoRepository egresoRepo;
  GenerarRecomendaciones(this.egresoRepo);

  @override
  Future<Either<Failure, List<Recomendacion>>> call(NoParams params) async {
    final result = await egresoRepo.obtenerEgresos();
    return result.fold(
      (l) => Left(l),
      (egresos) {
        final ocio = egresos.where((e) => e.categoria == CategoriaEgreso.ocio).fold(0.0, (s, e) => s + e.monto.valor);
        final total = egresos.fold(0.0, (s, e) => s + e.monto.valor);
        final porcOcio = total > 0 ? ocio / total : 0;
        List<Recomendacion> recs = [];
        if (porcOcio > 0.3) {
          recs.add(Recomendacion(mensaje: 'Tu gasto en ocio supera el 30%, intenta reducirlo.', categoria: 'gasto'));
        }
        recs.add(Recomendacion(mensaje: 'Considera automatizar un ahorro mensual.', categoria: 'ahorro'));
        return Right(recs);
      },
    );
  }
}