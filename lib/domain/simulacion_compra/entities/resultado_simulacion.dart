class ResultadoSimulacion {
  final double cuotaMensual;
  final double costoTotal;
  final bool esViable; // si cuota <= capacidad ahorro
  final String mensaje;
  final String? recomendacion; // meta de ahorro sugerida si no es viable

  const ResultadoSimulacion({
    required this.cuotaMensual,
    required this.costoTotal,
    required this.esViable,
    required this.mensaje,
    this.recomendacion,
  });
}