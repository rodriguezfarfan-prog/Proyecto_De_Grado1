import 'package:equatable/equatable.dart';
import 'recomendacion_detallada.dart';

class DiagnosticoResultado extends Equatable {
  final double capacidadAhorro;
  final double totalIngresos;
  final double totalEgresos;
  final double porcentajeAhorro;
  final String habito;
  final Map<String, double> actualPorGrupo;
  final Map<String, double> idealPorGrupo;
  final List<RecomendacionDetallada> recomendaciones;
  final double ahorroAdicionalEsperado;

  const DiagnosticoResultado({
    required this.capacidadAhorro,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.porcentajeAhorro,
    required this.habito,
    required this.actualPorGrupo,
    required this.idealPorGrupo,
    required this.recomendaciones,
    required this.ahorroAdicionalEsperado,
  });

  @override
  List<Object?> get props => [
    capacidadAhorro,
    totalIngresos,
    totalEgresos,
    porcentajeAhorro,
    habito,
    actualPorGrupo,
    idealPorGrupo,
    recomendaciones,
    ahorroAdicionalEsperado,
  ];
}
