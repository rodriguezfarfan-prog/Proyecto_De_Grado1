import '/domain/ahorro/entities/meta_ahorro.dart';
import '/core/value_objects/monto.dart';

class MetaAhorroModel {
  final String id;
  final String usuarioId;
  final String nombre;
  final double montoObjetivo;
  final double montoActual;
  final String fechaLimite; // ISO 8601
  final String? descripcion;

  MetaAhorroModel({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoActual,
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
    fechaLimite: json['fecha_limite'],
    descripcion: json['descripcion'],
  );
}

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nombre': nombre,
    'monto_objetivo': montoObjetivo,
    'monto_actual': montoActual,
    'fecha_limite': fechaLimite,
    'descripcion': descripcion,
  };

  MetaAhorro toDomain() => MetaAhorro(
    id: id,
    nombre: nombre,
    montoObjetivo: Monto(montoObjetivo),
    montoActual: Monto(montoActual),
    fechaLimite: DateTime.parse(fechaLimite),
    descripcion: descripcion,
  );
}