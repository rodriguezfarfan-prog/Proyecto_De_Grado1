import 'package:fin_up_project/core/value_objects/monto.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class MetaAhorro extends Equatable {
  final String id;
  final String nombre;
  final Monto montoObjetivo;
  final Monto montoActual;
  final double abonoMensualFijo; // ← NUEVO
  final DateTime fechaLimite;
  final String? descripcion;

  const MetaAhorro({
    required this.id,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoActual,
    required this.abonoMensualFijo,
    required this.fechaLimite,
    this.descripcion,
  });

  factory MetaAhorro.crear({
    required String nombre,
    required Monto montoObjetivo,
    required Monto montoActual,
    required int meses,
    String? descripcion,
  }) {
    final hoy = DateTime.now();
    final limite = DateTime(hoy.year, hoy.month + meses, hoy.day);
    final faltante = montoObjetivo.valor - montoActual.valor;
    final abono = meses > 0 ? faltante / meses : 0.0;

    return MetaAhorro(
      id: const Uuid().v4(),
      nombre: nombre,
      montoObjetivo: montoObjetivo,
      montoActual: montoActual,
      abonoMensualFijo: abono,
      fechaLimite: limite,
      descripcion: descripcion,
    );
  }

  double get progreso {
    if (montoObjetivo.valor <= 0) return 0;
    return (montoActual.valor / montoObjetivo.valor).clamp(0.0, 1.0);
  }

  int get mesesRestantes {
    final hoy = DateTime.now();
    final diff =
        (fechaLimite.year - hoy.year) * 12 + (fechaLimite.month - hoy.month);
    return diff <= 0 ? 1 : diff;
  }

  /// ✅ Ahora devuelve el abono fijo guardado, no recalculado
  double get abonoMensualNecesario => abonoMensualFijo;

  @override
  List<Object?> get props => [
    id,
    nombre,
    montoObjetivo,
    montoActual,
    abonoMensualFijo,
    fechaLimite,
    descripcion,
  ];
}
