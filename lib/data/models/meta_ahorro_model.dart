import 'package:fin_up_project/domain/ahorro/entities/meta_ahorro.dart';
import 'package:fin_up_project/core/value_objects/monto.dart';

class MetaAhorroModel {
  final String id;
  final String usuarioId;
  final String nombre;
  final double montoObjetivo;
  final double montoActual;
  final double abonoMensualFijo;
  final String fechaLimite;
  final String? descripcion;

  MetaAhorroModel({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoActual,
    required this.abonoMensualFijo,
    required this.fechaLimite,
    this.descripcion,
  });

  factory MetaAhorroModel.fromJson(Map<String, dynamic> json) {
    return MetaAhorroModel(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      montoObjetivo: (json['monto_objetivo'] as num).toDouble(),
      montoActual: (json['monto_actual'] as num).toDouble(),
      abonoMensualFijo: (json['abono_mensual_fijo'] as num?)?.toDouble() ?? 0.0,
      fechaLimite: json['fecha_limite'].toString().replaceFirst(' ', 'T'),
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nombre': nombre,
    'monto_objetivo': montoObjetivo,
    'monto_actual': montoActual,
    'abono_mensual_fijo': abonoMensualFijo,
    'fecha_limite': fechaLimite,
    'descripcion': descripcion,
  };

  MetaAhorro toDomain() => MetaAhorro(
    id: id,
    nombre: nombre,
    montoObjetivo: Monto(montoObjetivo),
    montoActual: Monto(montoActual),
    abonoMensualFijo: abonoMensualFijo,
    fechaLimite: DateTime.parse(fechaLimite),
    descripcion: descripcion,
  );
}
