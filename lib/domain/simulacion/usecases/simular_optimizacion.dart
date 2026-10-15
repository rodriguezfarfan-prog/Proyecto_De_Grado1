import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/usecase.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/domain/simulacion/entities/comparativa_gastos.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/egreso_repository.dart';

class SimularOptimizacion extends UseCase<ComparativaGastos, NoParams> {
  final EgresoRepository egresoRepo;
  SimularOptimizacion(this.egresoRepo);

  @override
  Future<Either<Failure, ComparativaGastos>> call(NoParams params) async {
    final result = await egresoRepo.obtenerEgresos();
    return result.fold((l) => Left(l), (egresos) {
      final Map<String, double> actual = {
        'primordial': 0.0,
        'entretenimiento': 0.0,
        'ocio': 0.0,
      };

      for (final e in egresos) {
        final key = e.grupo.name;
        actual[key] = (actual[key] ?? 0) + e.monto.valor;
      }

      // Ideal: primordial se mantiene, entretenimiento e ocio reducidos según regla
      final totalIngresos = actual.values.fold<double>(0.0, (a, b) => a + b);

      final ideal = {
        'primordial': actual['primordial'] ?? 0.0,
        'entretenimiento': actual['entretenimiento']! > (totalIngresos * 0.15)
            ? totalIngresos * 0.15
            : actual['entretenimiento']!,
        'ocio': totalIngresos * 0.15,
      };

      return Right(ComparativaGastos(actual: actual, ideal: ideal));
    });
  }
}
