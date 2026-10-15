import 'package:fin_up_project/domain/diagnostico/entities/egreso.dart';
import 'package:fin_up_project/core/value_objects/monto.dart';
import 'package:fin_up_project/core/value_objects/fecha.dart';

class EgresoModel {
  final String id;
  final String usuarioId;
  final double monto;
  final String fecha;
  final String? descripcion;
  final String grupo;
  final String subcategoria;
  final bool recurrente;

  EgresoModel({
    required this.id,
    required this.usuarioId,
    required this.monto,
    required this.fecha,
    this.descripcion,
    required this.grupo,
    required this.subcategoria,
    required this.recurrente,
  });

  factory EgresoModel.fromJson(Map<String, dynamic> json) => EgresoModel(
    id: json['id'],
    usuarioId: json['usuario_id'],
    monto: (json['monto'] as num).toDouble(),
    fecha: json['fecha'],
    descripcion: json['descripcion'],
    grupo: json['grupo'] ?? 'necesidad',
    subcategoria: json['subcategoria'] ?? 'otros',
    recurrente: json['recurrente'] == true || json['recurrente'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'monto': monto,
    'fecha': fecha,
    'descripcion': descripcion,
    'grupo': grupo,
    'subcategoria': subcategoria,
    'recurrente': recurrente,
  };

  Egreso toDomain() => Egreso(
    id: id,
    monto: Monto(monto),
    fecha: FechaFinanciera(DateTime.parse(fecha)),
    descripcion: descripcion,
    grupo: GrupoGasto.values.firstWhere(
      (e) => e.name == grupo,
      orElse: () => GrupoGasto.necesidad,
    ),
    subcategoria: subcategoria,
    recurrente: recurrente,
  );
}
