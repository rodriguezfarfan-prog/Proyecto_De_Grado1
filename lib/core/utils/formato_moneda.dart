import 'package:intl/intl.dart';

class FormatoMoneda {
  static final _formatter = NumberFormat('#,##0', 'es_CO');

  /// Formatea un número con separador de miles (punto).
  /// Ej: 3000000 → "3.000.000"
  static String formatear(num valor) {
    return _formatter.format(valor.round()).replaceAll(',', '.');
  }

  /// Formatea con símbolo de peso.
  /// Ej: 3000000 → "\$3.000.000"
  static String pesos(num valor) {
    return '\$${formatear(valor)}';
  }

  /// Formatea con decimales opcionales.
  /// Ej: 1500.5 → "1.500,50"
  static String formatearDecimales(num valor, {int decimales = 2}) {
    final f = NumberFormat('#,##0.${'0' * decimales}', 'es_CO');
    return f.format(valor).replaceAll(',', '.');
  }
}
