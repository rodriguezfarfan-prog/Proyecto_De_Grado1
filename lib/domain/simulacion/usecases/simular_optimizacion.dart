import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/simulacion/entities/comparativa_gastos.dart';
import '/domain/diagnostico/repositories/egreso_repository.dart';
import '/domain/diagnostico/entities/egreso.dart';

class SimularOptimizacion extends UseCase<ComparativaGastos, NoParams> {
  final EgresoRepository egresoRepo;
  SimularOptimizacion(this.egresoRepo);

  @override
  Future<Either<Failure, ComparativaGastos>> call(NoParams params) async {
    final result = await egresoRepo.obtenerEgresos();
    return result.fold(
      (l) => Left(l),
      (egresos) {
        final Map<CategoriaEgreso, double> actual = {};
        for (var e in egresos) {
          actual[e.categoria] = (actual[e.categoria] ?? 0) + e.monto.valor;
        }
        final total = actual.values.fold(0.0, (a, b) => a + b);
        final ideal = {
          CategoriaEgreso.vivienda: total * 0.35,
          CategoriaEgreso.alimentacion: total * 0.25,
          CategoriaEgreso.transporte: total * 0.15,
          CategoriaEgreso.educacion: total * 0.10,
          CategoriaEgreso.ocio: total * 0.10,
          CategoriaEgreso.otros: total * 0.05,
        };
        return Right(ComparativaGastos(actual: actual, ideal: ideal));
      },
    );
  }
}