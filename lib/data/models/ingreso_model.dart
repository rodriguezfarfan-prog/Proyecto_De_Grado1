import '/domain/diagnostico/entities/ingreso.dart';
import '/core/value_objects/monto.dart';
import '/core/value_objects/fecha.dart';

class IngresoModel {
  final String id;
  final String usuarioId;
  final double monto;
  final String fecha; // ISO 8601
  final String? descripcion;
  final String tipo;

  IngresoModel({
    required this.id,
    required this.usuarioId,
    required this.monto,
    required this.fecha,
    this.descripcion,
    required this.tipo,
  });

  factory IngresoModel.fromJson(Map<String, dynamic> json) {
  return IngresoModel(
    id: json['id'],
    usuarioId: json['usuario_id'],
    monto: (json['monto'] as num).toDouble(),
    fecha: json['fecha'],
    descripcion: json['descripcion'],
    tipo: json['tipo'],
  );
}

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'monto': monto,
    'fecha': fecha,
    'descripcion': descripcion,
    'tipo': tipo,
  };

  Ingreso toDomain() => Ingreso(
    id: id,
    monto: Monto(monto),
    fecha: FechaFinanciera(DateTime.parse(fecha)),
    descripcion: descripcion,
    tipo: TipoIngreso.values.firstWhere((e) => e.name == tipo),
  );
}