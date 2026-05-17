import '/domain/diagnostico/entities/egreso.dart';
import '/core/value_objects/monto.dart';
import '/core/value_objects/fecha.dart';

class EgresoModel {
  final String id;
  final String usuarioId;
  final double monto;
  final String fecha;
  final String? descripcion;
  final String categoria;
  final bool recurrente;

  EgresoModel({
    required this.id,
    required this.usuarioId,
    required this.monto,
    required this.fecha,
    this.descripcion,
    required this.categoria,
    required this.recurrente,
  });

  factory EgresoModel.fromJson(Map<String, dynamic> json) {
  return EgresoModel(
    id: json['id'],
    usuarioId: json['usuario_id'],
    monto: (json['monto'] as num).toDouble(),
    fecha: json['fecha'],
    descripcion: json['descripcion'],
    categoria: json['categoria'],
    recurrente: json['recurrente'] == true || json['recurrente'] == 1,
  );
}

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'monto': monto,
    'fecha': fecha,
    'descripcion': descripcion,
    'categoria': categoria,
    'recurrente': recurrente,
  };

  Egreso toDomain() => Egreso(
    id: id,
    monto: Monto(monto),
    fecha: FechaFinanciera(DateTime.parse(fecha)),
    descripcion: descripcion,
    categoria: CategoriaEgreso.values.firstWhere((e) => e.name == categoria),
    recurrente: recurrente,
  );
}