import '/core/value_objects/monto.dart';
import 'package:equatable/equatable.dart';

class MetaAhorro extends Equatable {
  final String id;
  final String nombre;
  final Monto montoObjetivo;
  final Monto montoActual;
  final DateTime fechaLimite;
  final String? descripcion;

  const MetaAhorro({
    required this.id,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoActual,
    required this.fechaLimite,
    this.descripcion,
  });

  double get progreso => (montoActual.valor / montoObjetivo.valor).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [id, nombre, montoObjetivo, montoActual, fechaLimite];
}