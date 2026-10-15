import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/usecase.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/domain/recomendacion/entities/recomendacion.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/egreso_repository.dart';

class GenerarRecomendaciones extends UseCase<List<Recomendacion>, NoParams> {
  final EgresoRepository egresoRepo;
  GenerarRecomendaciones(this.egresoRepo);

  @override
  Future<Either<Failure, List<Recomendacion>>> call(NoParams params) async {
    final result = await egresoRepo.obtenerEgresos();
    return result.fold((l) => Left(l), (egresos) {
      double totalOcio = 0;
      double totalEntretenimiento = 0;
      double total = 0;

      for (final e in egresos) {
        total += e.monto.valor;
        if (e.grupo.name == 'ocio') totalOcio += e.monto.valor;
        if (e.grupo.name == 'entretenimiento')
          totalEntretenimiento += e.monto.valor;
      }

      final recs = <Recomendacion>[];
      final porcOcio = total > 0 ? totalOcio / total : 0.0;
      final porcEntre = total > 0 ? totalEntretenimiento / total : 0.0;

      if (porcOcio > 0.15) {
        recs.add(
          Recomendacion(
            mensaje:
                'Tu gasto en ocio supera el 15% recomendado. Intenta reducirlo.',
            categoria: 'gasto',
          ),
        );
      }
      if (porcEntre > 0.15) {
        recs.add(
          Recomendacion(
            mensaje: 'Tu gasto en entretenimiento supera el 15% recomendado.',
            categoria: 'gasto',
          ),
        );
      }
      recs.add(
        Recomendacion(
          mensaje:
              'Considera automatizar un ahorro mensual del 20% de tus ingresos.',
          categoria: 'ahorro',
        ),
      );
      return Right(recs);
    });
  }
}
