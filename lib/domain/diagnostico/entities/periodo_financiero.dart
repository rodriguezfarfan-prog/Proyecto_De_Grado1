import 'package:equatable/equatable.dart';
import 'diagnostico_resultado.dart';

class PeriodoFinanciero extends Equatable {
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String nombreMes;
  final DiagnosticoResultado diagnostico;
  final bool esActual;

  const PeriodoFinanciero({
    required this.fechaInicio,
    required this.fechaFin,
    required this.nombreMes,
    required this.diagnostico,
    this.esActual = false,
  });

  @override
  List<Object?> get props => [
    fechaInicio,
    fechaFin,
    nombreMes,
    diagnostico,
    esActual,
  ];
}
