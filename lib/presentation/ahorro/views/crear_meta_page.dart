import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart';
import '../viewmodels/crear_meta_viewmodel.dart';
import '../../diagnostico/viewmodels/diagnostico_viewmodel.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';
import 'package:fin_up_project/core/utils/formato_moneda.dart';
import 'package:fin_up_project/presentation/gamificacion/viewmodels/gamificacion_viewmodel.dart';
import 'package:fin_up_project/presentation/gamificacion/views/logro_popup.dart';
import 'package:fin_up_project/domain/gamificacion/entities/logro.dart';

class CrearMetaPage extends ConsumerStatefulWidget {
  const CrearMetaPage({super.key});

  @override
  ConsumerState<CrearMetaPage> createState() => _CrearMetaPageState();
}

class _CrearMetaPageState extends ConsumerState<CrearMetaPage> {
  final _nombreCtrl = TextEditingController();
  final _objetivoCtrl = TextEditingController();
  final _actualCtrl = TextEditingController();
  final _mesesCtrl = TextEditingController(text: '6');
  final _descripcionCtrl = TextEditingController();

  double _capacidadAhorro = 0;
  bool _cargandoCapacidad = true;

  @override
  void initState() {
    super.initState();
    _objetivoCtrl.addListener(_recalcular);
    _actualCtrl.addListener(_recalcular);
    _mesesCtrl.addListener(_recalcular);

    Future.microtask(_cargarCapacidad);
  }

  Future<void> _cargarCapacidad() async {
    await ref.read(diagnosticoViewModelProvider.notifier).cargarTodo();
  }

  void _recalcular() {
    setState(() {});
  }

  double get _montoObjetivo => double.tryParse(_objetivoCtrl.text) ?? 0;
  double get _montoActual => double.tryParse(_actualCtrl.text) ?? 0;
  int get _meses => int.tryParse(_mesesCtrl.text) ?? 0;
  double get _abonoMensualNecesario {
    if (_meses <= 0) return 0;
    return (_montoObjetivo - _montoActual) / _meses;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crearMetaViewModelProvider);

    ref.listen<BaseState<MovimientosData>>(diagnosticoViewModelProvider, (
      previous,
      next,
    ) {
      if (next is Data<MovimientosData>) {
        setState(() {
          _capacidadAhorro = next.value.diagnosticoActual.capacidadAhorro;
          _cargandoCapacidad = false;
        });
      } else if (next is ErrorState) {
        setState(() => _cargandoCapacidad = false);
      }
    });

    // ✅ Al crear la meta exitosamente → logro + puntos + volver
    ref.listen<BaseState<Unit>>(crearMetaViewModelProvider, (
      previous,
      next,
    ) async {
      if (next is Data<Unit>) {
        final gamif = ref.read(gamificacionViewModelProvider.notifier);

        // 🎁 Logro de primera meta
        final logro = await gamif.desbloquearLogro(CatalogoLogros.primeraMeta);
        if (logro != null && mounted) {
          await mostrarLogroPopup(context, logro);
        }

        // ➕ Puntos recurrentes
        await gamif.registrarAccion('meta');

        if (mounted) context.pop();
      }
    });

    final mesesCompatibles =
        _abonoMensualNecesario <= _capacidadAhorro && _capacidadAhorro > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Meta de Ahorro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la meta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _objetivoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto objetivo (\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _actualCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto ya ahorrado (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mesesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '¿En cuántos meses deseas lograrlo?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            if (_cargandoCapacidad)
              const Center(child: CircularProgressIndicator())
            else
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.savings, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tu capacidad de ahorro mensual es: '
                          '${FormatoMoneda.pesos(_capacidadAhorro)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (_montoObjetivo > 0 && _meses > 0 && !_cargandoCapacidad) ...[
              Card(
                color: mesesCompatibles
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan de ahorro',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Abono mensual necesario: ${FormatoMoneda.pesos(_abonoMensualNecesario)}',
                      ),
                      Text('En $_meses meses'),
                      const SizedBox(height: 8),
                      if (mesesCompatibles)
                        const Text(
                          '✅ Este plan es compatible con tu capacidad de ahorro.',
                          style: TextStyle(color: Colors.green),
                        )
                      else ...[
                        const Text(
                          '⚠️ Este plan supera tu capacidad de ahorro actual.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _sugerenciaMes(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _guardar,
              child: const Text('Guardar Meta', style: TextStyle(fontSize: 16)),
            ),

            state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              data: (_) => const SizedBox.shrink(),
              error: (message) => Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sugerenciaMes() {
    if (_capacidadAhorro <= 0) {
      return 'Aún no tienes capacidad de ahorro. Considera primero reducir gastos de entretenimiento u ocio.';
    }
    final faltante = _montoObjetivo - _montoActual;
    final mesesSugeridos = (faltante / _capacidadAhorro).ceil();
    return 'Con tu capacidad de ahorro (${FormatoMoneda.pesos(_capacidadAhorro)}/mes), '
        'podrías alcanzarla en $mesesSugeridos meses.';
  }

  void _guardar() {
    final nombre = _nombreCtrl.text.trim();
    final objetivo = _montoObjetivo;
    final actual = _montoActual;
    final meses = _meses;

    if (nombre.isEmpty || objetivo <= 0 || meses <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa nombre, monto objetivo y meses'),
        ),
      );
      return;
    }

    ref
        .read(crearMetaViewModelProvider.notifier)
        .guardar(
          nombre: nombre,
          montoObjetivo: objetivo,
          montoActual: actual,
          meses: meses,
          descripcion: _descripcionCtrl.text,
        );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _objetivoCtrl.dispose();
    _actualCtrl.dispose();
    _mesesCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }
}
