import 'package:fin_up_project/core/value_objects/monto.dart';
import 'package:fin_up_project/core/value_objects/fecha.dart';
import 'package:equatable/equatable.dart';

enum TipoIngreso { sueldo, independiente, otros, beca, trabajo }

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

  Ingreso copyWith({
    Monto? monto,
    FechaFinanciera? fecha,
    String? descripcion,
    TipoIngreso? tipo,
  }) {
    return Ingreso(
      id: id,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  List<Object?> get props => [id, monto, fecha, tipo];
}

class EtiquetasIngreso {
  static const Map<TipoIngreso, String> labels = {
    TipoIngreso.sueldo: 'Sueldo',
    TipoIngreso.independiente: 'Independiente',
    TipoIngreso.otros: 'Otros',
    TipoIngreso.beca: 'Beca',
    TipoIngreso.trabajo: 'Trabajo',
  };
}
