import 'metodo_pago.dart';

class DatosCompra {
  final double precioProducto;
  final double cuotaInicial; // 0 si no hay
  final TipoMetodoPago metodo;
  final int? plazoMeses; // null para contado
  final double? tasaInteresMensual; // en decimal (ej. 0.02 para 2%)
  final double? montoTotalDevolver; // solo para préstamo informal

  const DatosCompra({
    required this.precioProducto,
    this.cuotaInicial = 0,
    required this.metodo,
    this.plazoMeses,
    this.tasaInteresMensual,
    this.montoTotalDevolver,
  });
}