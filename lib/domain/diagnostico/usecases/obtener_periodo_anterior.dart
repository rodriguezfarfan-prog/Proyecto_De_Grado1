import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/usecase.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/core/utils/calculadora_periodos.dart';
import 'package:fin_up_project/domain/diagnostico/entities/periodo_financiero.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/ingreso_repository.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/egreso_repository.dart';
import 'calcular_diagnostico.dart';

class ObtenerPeriodoAnteriorParams {
  final int diaInicio;
  const ObtenerPeriodoAnteriorParams({required this.diaInicio});
}

class ObtenerPeriodoAnterior
    extends UseCase<PeriodoFinanciero, ObtenerPeriodoAnteriorParams> {
  final IngresoRepository ingresoRepo;
  final EgresoRepository egresoRepo;

  ObtenerPeriodoAnterior(this.ingresoRepo, this.egresoRepo);

  @override
  Future<Either<Failure, PeriodoFinanciero>> call(
    ObtenerPeriodoAnteriorParams params,
  ) async {
    final ingresosEither = await ingresoRepo.obtenerIngresos();
    final egresosEither = await egresoRepo.obtenerEgresos();

    return ingresosEither.fold(
      (failure) => Left(failure),
      (ingresos) => egresosEither.fold((failure) => Left(failure), (egresos) {
        final hoy = DateTime.now();
        final rangoActual = CalculadoraPeriodos.rangoDeFecha(
          hoy,
          params.diaInicio,
        );
        final rangoAnterior = CalculadoraPeriodos.rangoAnterior(rangoActual);

        final ingresosMes = ingresos
            .where(
              (x) =>
                  !x.fecha.fecha.isBefore(rangoAnterior.inicio) &&
                  !x.fecha.fecha.isAfter(rangoAnterior.fin),
            )
            .toList();
        final egresosMes = egresos
            .where(
              (x) =>
                  !x.fecha.fecha.isBefore(rangoAnterior.inicio) &&
                  !x.fecha.fecha.isAfter(rangoAnterior.fin),
            )
            .toList();

        final diag = CalcularDiagnostico.calcular(ingresosMes, egresosMes);

        return Right(
          PeriodoFinanciero(
            fechaInicio: rangoAnterior.inicio,
            fechaFin: rangoAnterior.fin,
            nombreMes: CalculadoraPeriodos.nombreMes(rangoAnterior.inicio),
            diagnostico: diag,
            esActual: false,
          ),
        );
      }),
    );
  }
}
