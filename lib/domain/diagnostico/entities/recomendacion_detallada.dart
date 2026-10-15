class RecomendacionDetallada {
  final String grupo;
  final String subcategoria;
  final double gastoActual;
  final double gastoSugerido;
  final String mensaje;
  final double exceso;

  const RecomendacionDetallada({
    required this.grupo,
    required this.subcategoria,
    required this.gastoActual,
    required this.gastoSugerido,
    required this.mensaje,
    this.exceso = 0,
  });
}
