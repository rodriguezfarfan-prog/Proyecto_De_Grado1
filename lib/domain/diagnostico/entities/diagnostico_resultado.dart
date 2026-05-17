import 'package:equatable/equatable.dart';

class DiagnosticoResultado extends Equatable {
  final double capacidadAhorro;
  final double totalIngresos;
  final double totalEgresos;
  final double porcentajeAhorro;
  final String habito;
  final List<String> recomendacionesBasicas;

  const DiagnosticoResultado({
    required this.capacidadAhorro,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.porcentajeAhorro,
    required this.habito,
    required this.recomendacionesBasicas,
  });

  @override
  List<Object?> get props => [capacidadAhorro, totalIngresos, totalEgresos, porcentajeAhorro, habito];
}