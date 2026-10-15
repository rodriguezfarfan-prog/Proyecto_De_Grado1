class CalculadoraPeriodos {
  /// Dado un día de inicio (1-28) y una fecha, devuelve el rango del período
  /// al que pertenece esa fecha.
  static ({DateTime inicio, DateTime fin}) rangoDeFecha(
    DateTime fecha,
    int diaInicio,
  ) {
    final dia = diaInicio.clamp(1, 28);
    DateTime inicio, fin;

    if (fecha.day >= dia) {
      inicio = DateTime(fecha.year, fecha.month, dia);
      fin = DateTime(fecha.year, fecha.month + 1, dia - 1, 23, 59, 59);
    } else {
      inicio = DateTime(fecha.year, fecha.month - 1, dia);
      fin = DateTime(fecha.year, fecha.month, dia - 1, 23, 59, 59);
    }
    return (inicio: inicio, fin: fin);
  }

  /// Rango del período anterior al rango dado.
  static ({DateTime inicio, DateTime fin}) rangoAnterior(
    ({DateTime inicio, DateTime fin}) rangoActual,
  ) {
    final fechaReferencia = rangoActual.inicio.subtract(
      const Duration(days: 1),
    );
    // Recalculamos usando el mismo día
    final dia = rangoActual.inicio.day;
    return rangoDeFecha(fechaReferencia, dia);
  }

  static String nombreMes(DateTime fecha) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${meses[fecha.month - 1]} ${fecha.year}';
  }
}
