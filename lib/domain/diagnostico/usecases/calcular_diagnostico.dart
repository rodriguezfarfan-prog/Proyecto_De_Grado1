import 'package:fin_up_project/domain/diagnostico/entities/diagnostico_resultado.dart';
import 'package:fin_up_project/domain/diagnostico/entities/recomendacion_detallada.dart';
import 'package:fin_up_project/domain/diagnostico/entities/ingreso.dart';
import 'package:fin_up_project/domain/diagnostico/entities/egreso.dart';

class CalcularDiagnostico {
  static DiagnosticoResultado calcular(
    List<Ingreso> ingresos,
    List<Egreso> egresos,
  ) {
    final totalIngresos = ingresos.fold<double>(
      0.0,
      (sum, i) => sum + i.monto.valor,
    );

    final Map<String, double> actualPorGrupo = {
      'necesidad': 0.0,
      'entretenimiento': 0.0,
      'ocio': 0.0,
      'ahorro_deuda': 0.0,
    };
    final Map<String, Map<String, double>> porSubcat = {
      'necesidad': {},
      'entretenimiento': {},
      'ocio': {},
      'ahorro_deuda': {},
    };

    for (final e in egresos) {
      final g = e.grupo.name;
      actualPorGrupo[g] = (actualPorGrupo[g] ?? 0) + e.monto.valor;
      porSubcat[g]![e.subcategoria] =
          (porSubcat[g]![e.subcategoria] ?? 0) + e.monto.valor;
    }

    // ✅ NUEVO: el ahorro ya realizado (abonos a metas) NO resta de la capacidad.
    // Solo se consideran los gastos reales de necesidad/entretenimiento/ocio.
    final gastosReales =
        (actualPorGrupo['necesidad'] ?? 0) +
        (actualPorGrupo['entretenimiento'] ?? 0) +
        (actualPorGrupo['ocio'] ?? 0);

    // Total egresos mostrado al usuario (incluye los abonos para que los vea)
    final totalEgresos = actualPorGrupo.values.fold<double>(
      0.0,
      (a, b) => a + b,
    );

    // Capacidad de ahorro = ingresos - gastos reales (sin descontar ahorros)
    // Capacidad de ahorro = ingresos - gastos reales (sin descontar ahorros)
    final capacidadAhorro = totalIngresos - gastosReales;

    // ✅ Porcentaje = solo la capacidad de ahorro sobre los ingresos.
    // No se suma lo ya abonado para evitar que crezca con cada abono.
    final porcentajeAhorro = totalIngresos > 0
        ? (capacidadAhorro / totalIngresos) * 100.0
        : 0.0;

    final habito = _clasificar(porcentajeAhorro);

    final Map<String, double> idealPorGrupo = {};
    idealPorGrupo['necesidad'] = actualPorGrupo['necesidad']!;

    final maxEntre = totalIngresos * 0.15;
    idealPorGrupo['entretenimiento'] =
        actualPorGrupo['entretenimiento']! > maxEntre
        ? maxEntre
        : actualPorGrupo['entretenimiento']!;

    final maxOcio = totalIngresos * 0.15;
    idealPorGrupo['ocio'] = actualPorGrupo['ocio']! > maxOcio
        ? maxOcio
        : actualPorGrupo['ocio']!;

    idealPorGrupo['ahorro_deuda'] = actualPorGrupo['ahorro_deuda']!;

    final recomendaciones = <RecomendacionDetallada>[];

    if (actualPorGrupo['entretenimiento']! > maxEntre) {
      final exceso = actualPorGrupo['entretenimiento']! - maxEntre;
      final totalAct = actualPorGrupo['entretenimiento']!;
      for (final entry in porSubcat['entretenimiento']!.entries) {
        final prop = totalAct > 0 ? entry.value / totalAct : 0.0;
        final reduc = exceso * prop;
        recomendaciones.add(
          RecomendacionDetallada(
            grupo: 'entretenimiento',
            subcategoria: entry.key,
            gastoActual: entry.value,
            gastoSugerido: (entry.value - reduc).clamp(0, double.infinity),
            mensaje:
                'Reducir \$${reduc.toStringAsFixed(0)} y aportar a ahorro o deuda',
            exceso: reduc,
          ),
        );
      }
    }

    if (actualPorGrupo['ocio']! > maxOcio) {
      final exceso = actualPorGrupo['ocio']! - maxOcio;
      final totalAct = actualPorGrupo['ocio']!;
      for (final entry in porSubcat['ocio']!.entries) {
        final prop = totalAct > 0 ? entry.value / totalAct : 0.0;
        final reduc = exceso * prop;
        recomendaciones.add(
          RecomendacionDetallada(
            grupo: 'ocio',
            subcategoria: entry.key,
            gastoActual: entry.value,
            gastoSugerido: (entry.value - reduc).clamp(0, double.infinity),
            mensaje:
                'Reducir \$${reduc.toStringAsFixed(0)} y aportar a ahorro o deuda',
            exceso: reduc,
          ),
        );
      }
    }

    final ahorroAdicional =
        (actualPorGrupo['entretenimiento']! -
            idealPorGrupo['entretenimiento']!) +
        (actualPorGrupo['ocio']! - idealPorGrupo['ocio']!);

    return DiagnosticoResultado(
      capacidadAhorro: capacidadAhorro,
      totalIngresos: totalIngresos,
      totalEgresos: totalEgresos,
      porcentajeAhorro: porcentajeAhorro,
      habito: habito,
      actualPorGrupo: actualPorGrupo,
      idealPorGrupo: idealPorGrupo,
      recomendaciones: recomendaciones,
      ahorroAdicionalEsperado: ahorroAdicional,
    );
  }

  static String _clasificar(double p) {
    if (p >= 20) return 'Excelente';
    if (p >= 10) return 'Bueno';
    if (p >= 0) return 'Ajustado';
    return 'Deficiente';
  }
}
