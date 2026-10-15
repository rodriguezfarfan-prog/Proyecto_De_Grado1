import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _keyDiaInicio = 'dia_inicio_periodo';
  static const int _defaultDiaInicio = 1;

  static Future<int> obtenerDiaInicio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDiaInicio) ?? _defaultDiaInicio;
  }

  static Future<void> guardarDiaInicio(int dia) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDiaInicio, dia.clamp(1, 28));
  }
}
