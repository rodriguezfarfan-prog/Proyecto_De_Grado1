import '/core/value_objects/monto.dart';
import '/core/value_objects/fecha.dart';
import 'package:equatable/equatable.dart';

enum TipoIngreso { mensual, ocasional, beca, trabajo }

class Ingreso extends Equatable {
  final String id;
  final Monto monto;
  final FechaFinanciera fecha;
  final String? descripcion;
  final TipoIngreso tipo;

  const Ingreso({
    required this.id,
    required this.monto,
    required this.fecha,
    this.descripcion,
    required this.tipo,
  });

  @override
  List<Object?> get props => [id, monto, fecha, tipo];
}