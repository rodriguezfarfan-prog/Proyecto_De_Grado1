import '/core/value_objects/monto.dart';
import '/core/value_objects/fecha.dart';
import 'package:equatable/equatable.dart';

enum CategoriaEgreso { alimentacion, transporte, ocio, vivienda, educacion, otros }

class Egreso extends Equatable {
  final String id;
  final Monto monto;
  final FechaFinanciera fecha;
  final String? descripcion;
  final CategoriaEgreso categoria;
  final bool recurrente;

  const Egreso({
    required this.id,
    required this.monto,
    required this.fecha,
    this.descripcion,
    required this.categoria,
    required this.recurrente,
  });

  @override
  List<Object?> get props => [id, monto, fecha, categoria, recurrente];
}