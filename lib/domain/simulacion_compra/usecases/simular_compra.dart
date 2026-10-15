import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/diagnostico/repositories/ingreso_repository.dart';
import '/domain/diagnostico/repositories/egreso_repository.dart';
import '/domain/simulacion_compra/entities/datos_compra.dart';
import '/domain/simulacion_compra/entities/resultado_simulacion.dart';
import '/domain/simulacion_compra/entities/metodo_pago.dart';

class SimularCompra extends UseCase<ResultadoSimulacion, DatosCompra> {
  final IngresoRepository ingresoRepo;
  final EgresoRepository egresoRepo;

  SimularCompra(this.ingresoRepo, this.egresoRepo);

  @override
  Future<Either<Failure, ResultadoSimulacion>> call(DatosCompra params) async {
    // Obtener capacidad de ahorro actual
    final ingresosEither = await ingresoRepo.obtenerIngresos();
    final egresosEither = await egresoRepo.obtenerEgresos();

    return ingresosEither.fold(
      (l) => Left(l),
      (ingresos) => egresosEither.fold((l) => Left(l), (egresos) {
        final ingresoTotal = ingresos.fold<double>(
          0,
          (s, i) => s + i.monto.valor,
        );
        final egresoTotal = egresos.fold<double>(
          0,
          (s, e) => s + e.monto.valor,
        );
        final capacidadAhorro = ingresoTotal - egresoTotal;
        if (capacidadAhorro <= 0) {
          return Right(
            ResultadoSimulacion(
              cuotaMensual: 0,
              costoTotal: 0,
              esViable: false,
              mensaje:
                  'No tienes capacidad de ahorro. Te recomendamos no realizar esta compra.',
              recomendacion: 'Ahorra primero para un fondo de emergencia.',
            ),
          );
        }

        double cuota;
        double costoTotal;
        switch (params.metodo) {
          case TipoMetodoPago.contado:
            cuota = params.precioProducto;
            costoTotal = params.precioProducto;
            break;
          case TipoMetodoPago.tarjetaCredito:
          case TipoMetodoPago.creditoConsumo:
            final montoFinanciar = params.precioProducto - params.cuotaInicial;
            final n = params.plazoMeses ?? 12;
            final i =
                params.tasaInteresMensual ?? 0.025; // 2.5% mensual por defecto
            if (i == 0) {
              cuota = montoFinanciar / n;
              costoTotal = montoFinanciar;
            } else {
              final factor = (1 - 1 / _pow(1 + i, n)) / i;
              cuota = montoFinanciar / factor;
              costoTotal = cuota * n;
            }
            break;
          case TipoMetodoPago.compraAhoraPagaDespues:
            final n = params.plazoMeses ?? 3;
            final i =
                params.tasaInteresMensual ??
                0.0; // asume 0% si no se especifica
            if (i == 0) {
              cuota = params.precioProducto / n;
              costoTotal = params.precioProducto;
            } else {
              final factor = (1 - 1 / _pow(1 + i, n)) / i;
              cuota = params.precioProducto / factor;
              costoTotal = cuota * n;
            }
            break;
          case TipoMetodoPago.prestamoInformal:
            final monto = params.montoTotalDevolver ?? params.precioProducto;
            final n = params.plazoMeses ?? 1;
            cuota = monto / n;
            costoTotal = monto;
            break;
        }

        final viable = cuota <= capacidadAhorro;
        String mensaje;
        String? recomendacion;
        if (viable) {
          mensaje =
              'La cuota de \$${cuota.toStringAsFixed(0)} está dentro de tu capacidad de ahorro (\$${capacidadAhorro.toStringAsFixed(0)}).';
        } else {
          mensaje =
              'La cuota de \$${cuota.toStringAsFixed(0)} supera tu capacidad de ahorro (\$${capacidadAhorro.toStringAsFixed(0)}). Te recomendamos no realizar esta compra.';
          // Sugerir meta de ahorro si supera la capacidad de ahorro
          final ahorroNecesario = cuota - capacidadAhorro;
          if (ahorroNecesario > 0) {
            recomendacion = 'Podrías crear una meta de ahorro.';
          }
        }

        return Right(
          ResultadoSimulacion(
            cuotaMensual: cuota,
            costoTotal: costoTotal,
            esViable: viable,
            mensaje: mensaje,
            recomendacion: recomendacion,
          ),
        );
      }),
    );
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
