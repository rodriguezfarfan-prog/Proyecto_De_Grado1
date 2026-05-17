import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/diagnostico/entities/diagnostico_resultado.dart';
import '/domain/diagnostico/repositories/ingreso_repository.dart';
import '/domain/diagnostico/repositories/egreso_repository.dart';

class RealizarDiagnostico extends UseCase<DiagnosticoResultado, NoParams> {
  final IngresoRepository ingresoRepo;
  final EgresoRepository egresoRepo;

  RealizarDiagnostico(this.ingresoRepo, this.egresoRepo);

  @override
  Future<Either<Failure, DiagnosticoResultado>> call(NoParams params) async {
    final ingresosEither = await ingresoRepo.obtenerIngresos();
    final egresosEither = await egresoRepo.obtenerEgresos();

    return ingresosEither.fold(
      (failure) => Left(failure),
      (ingresos) => egresosEither.fold(
        (failure) => Left(failure),
        (egresos) {
          final totalIngresos = ingresos.fold<double>(0.0, (sum, i) => sum + i.monto.valor); // forzar tipo
          final totalEgresos = egresos.fold<double>(0.0, (sum, e) => sum + e.monto.valor);
          final capacidad = totalIngresos - totalEgresos;
          final porcentaje = totalIngresos > 0 ? (capacidad / totalIngresos) * 100 : 0.0; // garantiza double
          final habito = _clasificarHabito(porcentaje);
          return Right(DiagnosticoResultado(
            capacidadAhorro: capacidad,
            totalIngresos: totalIngresos,
            totalEgresos: totalEgresos,
            porcentajeAhorro: porcentaje,
            habito: habito,
            recomendacionesBasicas: _recomendaciones(habito),
          ));
        },
      ),
    );
  }

  String _clasificarHabito(double p) {
    if (p >= 20) return 'Excelente';
    if (p >= 10) return 'Bueno';
    if (p >= 0) return 'Ajustado';
    return 'Deficitario';
  }

  List<String> _recomendaciones(String habito) {
    switch (habito) {
      case 'Deficitario':
        return ['Reduce ocio', 'Busca ingresos extra', 'Evita deudas'];
      case 'Ajustado':
        return ['Crea fondo de emergencia', 'Revisa suscripciones'];
      default:
        return ['Mantén el hábito', 'Invierte a largo plazo'];
    }
  }
}