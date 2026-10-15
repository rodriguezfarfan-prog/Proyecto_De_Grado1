import 'package:flutter/material.dart';
import 'package:fin_up_project/core/services/notification_service.dart';
import 'package:fin_up_project/core/models/notification_config.dart';

/// Muestra el diálogo de programación de notificaciones.
/// Se puede abrir desde cualquier pantalla.
Future<void> mostrarDialogoNotificaciones(BuildContext context) async {
  final permisos = await NotificationService.pedirPermisos();
  if (!permisos) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de notificaciones denegado')),
      );
    }
    return;
  }
  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) => const NotificacionesDialog(),
  );
}

/// Botón con ícono + texto para programar notificaciones.
/// Se usa en AppBar como acción o en cualquier lugar.
class BotonProgramarNotificaciones extends StatelessWidget {
  const BotonProgramarNotificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => mostrarDialogoNotificaciones(context),
      icon: const Icon(Icons.notifications_active_outlined, size: 20),
      label: const Text('Programar notificaciones'),
      style: TextButton.styleFrom(foregroundColor: Colors.teal),
    );
  }
}

/// Diálogo de notificaciones (widget interno).
class NotificacionesDialog extends StatefulWidget {
  const NotificacionesDialog({super.key});

  @override
  State<NotificacionesDialog> createState() => _NotificacionesDialogState();
}

class _NotificacionesDialogState extends State<NotificacionesDialog> {
  bool _diariaActiva = false;
  bool _abonoActivo = false;
  List<NotificacionConfig> _customs = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final diaria = await NotificationService.diariaActiva();
    final customs = await NotificationService.listarCustom();
    setState(() {
      _diariaActiva = diaria;
      _customs = customs;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      title: const Text('Programar notificaciones'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Diaria ──
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Registrar gastos diariamente'),
                subtitle: const Text('Todos los días a las 8:00 AM'),
                value: _diariaActiva,
                onChanged: (v) async {
                  if (v) {
                    await NotificationService.activarDiaria();
                  } else {
                    await NotificationService.desactivarDiaria();
                  }
                  setState(() => _diariaActiva = v);
                },
              ),
              const Divider(),

              // ── Abono a metas ──
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recordar abono a metas'),
                subtitle: const Text('Día 1 de cada mes, 9:00 AM'),
                value: _abonoActivo,
                onChanged: (v) async {
                  if (v) {
                    await NotificationService.programarAbonoMeta();
                  } else {
                    await NotificationService.cancelarAbonoMeta();
                  }
                  setState(() => _abonoActivo = v);
                },
              ),
              const Divider(),

              // ── Personalizadas ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recordatorios personalizados',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.teal),
                    onPressed: _agregarCustom,
                    tooltip: 'Agregar',
                  ),
                ],
              ),
              if (_customs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Aún no has creado recordatorios personalizados.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
              else
                ..._customs.map(
                  (c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.notifications_active,
                      color: Colors.teal,
                    ),
                    title: Text(c.titulo),
                    subtitle: Text(
                      '${c.frecuencia == 'quincenal' ? 'Quincenal' : 'Mensual'} '
                      '${c.frecuencia == 'quincenal' ? '(día 1 y 15)' : '(día ${c.dia})'} '
                      '· ${c.hora.toString().padLeft(2, '0')}:${c.minuto.toString().padLeft(2, '0')}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await NotificationService.eliminarCustom(c.id);
                        await _cargar();
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Future<void> _agregarCustom() async {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final diaCtrl = TextEditingController(text: '1');
    String frecuencia = 'mensual';
    TimeOfDay hora = const TimeOfDay(hour: 9, minute: 0);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInner) => AlertDialog(
          title: const Text('Nuevo recordatorio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre (ej. Pago tarjeta)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: frecuencia,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                    DropdownMenuItem(
                      value: 'quincenal',
                      child: Text('Quincenal (día 1 y 15)'),
                    ),
                  ],
                  onChanged: (v) => setInner(() => frecuencia = v!),
                ),
                if (frecuencia == 'mensual') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: diaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Día del mes (1-31)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Hora: ${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: hora,
                    );
                    if (picked != null) setInner(() => hora = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    final titulo = tituloCtrl.text.trim();
    if (titulo.isEmpty) return;

    final dia = frecuencia == 'quincenal'
        ? 1
        : (int.tryParse(diaCtrl.text) ?? 1).clamp(1, 31);

    final id = await NotificationService.siguienteIdCustom();

    await NotificationService.agregarCustom(
      NotificacionConfig(
        id: id,
        titulo: titulo,
        descripcion: descCtrl.text.trim().isEmpty
            ? 'Recordatorio FinUp'
            : descCtrl.text.trim(),
        frecuencia: frecuencia,
        dia: dia,
        hora: hora.hour,
        minuto: hora.minute,
      ),
    );

    await _cargar();
  }
}
