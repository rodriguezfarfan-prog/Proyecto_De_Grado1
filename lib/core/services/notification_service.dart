import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_config.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const String _keyNotificacionesCustom = 'notificaciones_custom';
  static const String _keyDailyActiva = 'notif_daily_activa';
  static const String _keyHoraPrimeraRacha = 'hora_primera_racha';

  static const int _idDaily = 100;
  static const int _idAbonoMeta = 1;
  static const int _idRacha = 300;
  static const int _idCustomBase = 200; // ids 200+ para personalizadas

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<bool> pedirPermisos() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ─────────────────────────────────────────────────────────────
  // DIARIA a las 8 AM
  // ─────────────────────────────────────────────────────────────

  static Future<void> activarDiaria() async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyActiva, true);

    const androidDetails = AndroidNotificationDetails(
      'finup_diaria',
      'Recordatorio diario FinUp',
      channelDescription: 'Recordatorio diario para registrar tus gastos',
      importance: Importance.high,
      priority: Priority.high,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _idDaily,
      '📝 Registra tus gastos de hoy',
      'Mantén tu diagnóstico financiero al día.',
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> desactivarDiaria() async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyActiva, false);
    await _plugin.cancel(_idDaily);
  }

  static Future<bool> diariaActiva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDailyActiva) ?? false;
  }

  // ─────────────────────────────────────────────────────────────
  // ABONO A METAS (fijo)
  // ─────────────────────────────────────────────────────────────

  static Future<void> programarAbonoMeta() async {
    await init();
    await _programarMensual(
      id: _idAbonoMeta,
      titulo: '💰 Recuerda abonar a tus metas',
      cuerpo: 'Es momento de sumar a tu ahorro este mes.',
      dia: 1,
      hora: 9,
      minuto: 0,
    );
  }

  static Future<void> cancelarAbonoMeta() async {
    await init();
    await _plugin.cancel(_idAbonoMeta);
  }

  // ─────────────────────────────────────────────────────────────
  // RECORDATORIO DE RACHA (1 hora antes de la hora de primera visita)
  // ─────────────────────────────────────────────────────────────

  /// Programa el recordatorio 1 hora antes de la hora en que el usuario
  /// registró la racha por primera vez.
  /// [rachaActual] se usa para saber si la racha se reinició:
  /// - Si racha == 1 → guarda la hora actual como nueva base.
  /// - Si racha > 1 → usa la hora guardada anteriormente.
  static Future<void> programarRecordatorioRacha(int rachaActual) async {
    await init();
    final prefs = await SharedPreferences.getInstance();

    final ahora = tz.TZDateTime.now(tz.local);
    String? horaGuardada = prefs.getString(_keyHoraPrimeraRacha);

    // Si es la primera vez o la racha se reinició → guardar hora actual
    if (horaGuardada == null || rachaActual <= 1) {
      horaGuardada =
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
      await prefs.setString(_keyHoraPrimeraRacha, horaGuardada);
      print(
        '🔔 Nueva hora de racha guardada: $horaGuardada (racha=$rachaActual)',
      );
    } else {
      print('🔔 Manteniendo hora guardada: $horaGuardada (racha=$rachaActual)');
    }

    // Parsear hora guardada
    final partes = horaGuardada.split(':');
    final horaRegistro = int.parse(partes[0]);
    final minutoRegistro = int.parse(partes[1]);

    // Calcular 1 hora antes
    int horaRecordatorio = horaRegistro - 1;
    if (horaRecordatorio < 0) horaRecordatorio = 23;

    // Programar para hoy o mañana
    var scheduled = tz.TZDateTime(
      tz.local,
      ahora.year,
      ahora.month,
      ahora.day,
      horaRecordatorio,
      minutoRegistro,
    );
    if (scheduled.isBefore(ahora)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'finup_racha',
      'Recordatorio de racha',
      channelDescription: 'Te recuerda entrar para mantener tu racha diaria',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      _idRacha,
      '🔥 ¡No pierdas tu racha!',
      'Tienes 1 hora para mantener tu racha. Entra ahora a FinUp.',
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print(
      '🔔 Recordatorio programado para las ${horaRecordatorio.toString().padLeft(2, '0')}:${minutoRegistro.toString().padLeft(2, '0')}',
    );
  }

  static Future<void> cancelarRecordatorioRacha() async {
    await init();
    await _plugin.cancel(_idRacha);
    print('🔕 Recordatorio de racha cancelado');
  }

  /// Resetea la hora guardada. La próxima vez que se programe el recordatorio
  /// se usará la hora actual como nueva base.
  static Future<void> resetearHoraRacha() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHoraPrimeraRacha);
    print('🔄 Hora de racha reseteada');
  }

  // ─────────────────────────────────────────────────────────────
  // PERSONALIZADAS (mensual o quincenal)
  // ─────────────────────────────────────────────────────────────

  static Future<List<NotificacionConfig>> listarCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyNotificacionesCustom) ?? [];
    return raw
        .map(
          (s) => NotificacionConfig.fromJson(
            jsonDecode(s) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static Future<void> agregarCustom(NotificacionConfig config) async {
    await init();

    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final lista = await listarCustom();
    lista.add(config);
    await prefs.setStringList(
      _keyNotificacionesCustom,
      lista.map((c) => jsonEncode(c.toJson())).toList(),
    );

    // Programar
    await _programarCustom(config);
  }

  static Future<void> eliminarCustom(int id) async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    final lista = await listarCustom();
    lista.removeWhere((c) => c.id == id);
    await prefs.setStringList(
      _keyNotificacionesCustom,
      lista.map((c) => jsonEncode(c.toJson())).toList(),
    );

    // Cancelar notificaciones (quincenal usa 2 IDs)
    await _plugin.cancel(id);
    if (id >= _idCustomBase) {
      await _plugin.cancel(id + 1); // por si era quincenal
    }
  }

  static Future<void> _programarCustom(NotificacionConfig c) async {
    if (c.frecuencia == 'quincenal') {
      // Programar día 1 y día 15
      await _programarMensual(
        id: c.id,
        titulo: c.titulo,
        cuerpo: c.descripcion,
        dia: 1,
        hora: c.hora,
        minuto: c.minuto,
      );
      await _programarMensual(
        id: c.id + 1,
        titulo: c.titulo,
        cuerpo: c.descripcion,
        dia: 15,
        hora: c.hora,
        minuto: c.minuto,
      );
    } else {
      // Mensual normal
      await _programarMensual(
        id: c.id,
        titulo: c.titulo,
        cuerpo: c.descripcion,
        dia: c.dia,
        hora: c.hora,
        minuto: c.minuto,
      );
    }
  }

  static Future<int> siguienteIdCustom() async {
    final lista = await listarCustom();
    if (lista.isEmpty) return _idCustomBase;
    final maxId = lista.map((c) => c.id).reduce((a, b) => a > b ? a : b);
    return maxId + 10;
  }

  // ─────────────────────────────────────────────────────────────
  // UTILIDAD INTERNA
  // ─────────────────────────────────────────────────────────────

  static Future<void> _programarMensual({
    required int id,
    required String titulo,
    required String cuerpo,
    required int dia,
    required int hora,
    required int minuto,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      dia,
      hora,
      minuto,
    );
    if (scheduled.isBefore(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        dia,
        hora,
        minuto,
      );
    }

    const androidDetails = AndroidNotificationDetails(
      'finup_recordatorios',
      'Recordatorios FinUp',
      channelDescription: 'Recordatorios personalizados de gastos',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  static Future<void> cancelarTodo() async {
    await init();
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyActiva, false);
    await prefs.remove(_keyNotificacionesCustom);
    await prefs.remove(_keyHoraPrimeraRacha);
  }
}
