import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/ahorro_viewmodel.dart';
import 'package:fin_up_project/domain/ahorro/entities/meta_ahorro.dart';
import 'package:fin_up_project/core/utils/formato_moneda.dart';
import 'package:fin_up_project/presentation/shared/notificaciones_dialog.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';
import 'package:fin_up_project/presentation/gamificacion/viewmodels/gamificacion_viewmodel.dart';
import 'package:fin_up_project/presentation/gamificacion/views/logro_popup.dart';
import 'package:fin_up_project/domain/gamificacion/entities/logro.dart';

class AhorroPage extends ConsumerStatefulWidget {
  const AhorroPage({super.key});

  @override
  ConsumerState<AhorroPage> createState() => _AhorroPageState();
}

class _AhorroPageState extends ConsumerState<AhorroPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ahorroViewModelProvider.notifier).cargarMetas();
    });
  }

  Future<void> _mostrarDialogoAbono(MetaAhorro meta) async {
    final abonoPropuesto = meta.abonoMensualNecesario;
    final controller = TextEditingController(
      text: abonoPropuesto.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();
    double montoActualDialogo = abonoPropuesto;

    final monto = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final esMenor =
                montoActualDialogo > 0 && montoActualDialogo < abonoPropuesto;

            String? advertenciaMeses;
            if (esMenor && montoActualDialogo > 0) {
              final faltante =
                  meta.montoObjetivo.valor - meta.montoActual.valor;
              final mesesOriginales = (faltante / abonoPropuesto).ceil();
              final mesesNuevos = (faltante / montoActualDialogo).ceil();
              final mesesExtra = mesesNuevos - mesesOriginales;
              advertenciaMeses =
                  'Con este abono tardarás $mesesExtra mes(es) más '
                  'en cumplir tu meta ($mesesNuevos meses en total).';
            }

            return AlertDialog(
              title: Text('Abonar a "${meta.nombre}"'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Abono mensual propuesto: ${FormatoMoneda.pesos(abonoPropuesto)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Meses restantes: ${meta.mesesRestantes}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monto a abonar (\$)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          setStateDialog(() {
                            montoActualDialogo = double.tryParse(v) ?? 0;
                          });
                        },
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n <= 0) {
                            return 'Ingresa un monto válido';
                          }
                          final restante =
                              meta.montoObjetivo.valor - meta.montoActual.valor;
                          if (n > restante) {
                            return 'Supera el monto restante';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (esMenor) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Si abonas menos de la cantidad propuesta, '
                                  'tardarás más en cumplir tu meta.\n\n'
                                  '$advertenciaMeses',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (montoActualDialogo >= abonoPropuesto &&
                          abonoPropuesto > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vas por buen camino. Cumplirás tu meta a tiempo.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(ctx, double.parse(controller.text));
                    }
                  },
                  child: const Text('Abonar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (monto == null) return;

    final error = await ref
        .read(ahorroViewModelProvider.notifier)
        .agregarAbono(meta.id, monto);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      final gamif = ref.read(gamificacionViewModelProvider.notifier);

      // 🎁 Logro de primer abono
      final logro = await gamif.desbloquearLogro(CatalogoLogros.primerAbono);
      if (logro != null && mounted) {
        await mostrarLogroPopup(context, logro);
      }

      // ➕ Puntos recurrentes
      await gamif.registrarAccion('abono');
    }
  }

  Future<void> _confirmarEliminacion(MetaAhorro meta) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text('¿Seguro que deseas eliminar "${meta.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await ref.read(ahorroViewModelProvider.notifier).eliminarMeta(meta.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ahorroViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de Ahorro'),
        actions: const [BotonProgramarNotificaciones()],
      ),
      body: state.when(
        initial: () => const Center(child: Text('Cargando...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (resumen) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total ahorrado',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        FormatoMoneda.pesos(resumen.totalAhorrado),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: resumen.metas.isEmpty
                  ? const Center(child: Text('No tienes metas de ahorro.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: resumen.metas.length,
                      itemBuilder: (context, index) {
                        final meta = resumen.metas[index];
                        final progreso = meta.montoObjetivo.valor > 0
                            ? (meta.montoActual.valor /
                                      meta.montoObjetivo.valor)
                                  .clamp(0.0, 1.0)
                            : 0.0;
                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(meta.nombre),
                                subtitle: Text(
                                  'Meta: ${FormatoMoneda.pesos(meta.montoObjetivo.valor)} · '
                                  'Ahorrado: ${FormatoMoneda.pesos(meta.montoActual.valor)}\n'
                                  'Abono mensual propuesto: ${FormatoMoneda.pesos(meta.abonoMensualNecesario)}',
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      color: Colors.teal,
                                      onPressed: () =>
                                          _mostrarDialogoAbono(meta),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                      onPressed: () =>
                                          _confirmarEliminacion(meta),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: LinearProgressIndicator(
                                  value: progreso,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.teal,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        error: (message) => Center(child: Text('Error: $message')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/crear-meta');
          ref.read(ahorroViewModelProvider.notifier).cargarMetas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
