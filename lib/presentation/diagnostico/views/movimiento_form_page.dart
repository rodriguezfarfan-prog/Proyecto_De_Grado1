import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fin_up_project/core/value_objects/monto.dart';
import 'package:fin_up_project/core/value_objects/fecha.dart';
import 'package:fin_up_project/domain/diagnostico/entities/egreso.dart';
import 'package:fin_up_project/domain/diagnostico/entities/ingreso.dart';
import '../viewmodels/diagnostico_viewmodel.dart';
import 'package:fin_up_project/presentation/gamificacion/viewmodels/gamificacion_viewmodel.dart';
import 'package:fin_up_project/presentation/gamificacion/views/logro_popup.dart';
import 'package:fin_up_project/domain/gamificacion/entities/logro.dart';

class MovimientoFormPage extends ConsumerStatefulWidget {
  final Ingreso? ingreso;
  final Egreso? egreso;

  const MovimientoFormPage({super.key, this.ingreso, this.egreso});

  @override
  ConsumerState<MovimientoFormPage> createState() => _MovimientoFormPageState();
}

class _MovimientoFormPageState extends ConsumerState<MovimientoFormPage> {
  int _tipo = 0;

  TipoIngreso _tipoIngreso = TipoIngreso.sueldo;

  GrupoGasto _grupo = GrupoGasto.necesidad;
  String _subcategoria = SubcategoriasGasto.obtener(GrupoGasto.necesidad).first;

  final _montoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.ingreso != null) {
      _tipo = 0;
      _tipoIngreso = widget.ingreso!.tipo;
      _montoCtrl.text = widget.ingreso!.monto.valor.toStringAsFixed(0);
      _descCtrl.text = widget.ingreso!.descripcion ?? '';
      _fecha = widget.ingreso!.fecha.fecha;
    } else if (widget.egreso != null) {
      _tipo = 1;
      _grupo = widget.egreso!.grupo;
      _subcategoria = widget.egreso!.subcategoria;
      _montoCtrl.text = widget.egreso!.monto.valor.toStringAsFixed(0);
      _descCtrl.text = widget.egreso!.descripcion ?? '';
      _fecha = widget.egreso!.fecha.fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.ingreso != null || widget.egreso != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar movimiento' : 'Nuevo movimiento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!esEdicion) ...[
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Ingreso'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Gasto'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) => setState(() => _tipo = s.first),
              ),
              const SizedBox(height: 20),
            ],

            TextField(
              controller: _montoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _fecha,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _fecha = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                ),
                child: Text('${_fecha.day}/${_fecha.month}/${_fecha.year}'),
              ),
            ),
            const SizedBox(height: 16),

            if (_tipo == 0) _buildSelectorIngreso(),
            if (_tipo == 1) _buildSelectorEgreso(),

            const SizedBox(height: 16),

            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(esEdicion ? 'Actualizar' : 'Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorIngreso() {
    return DropdownButtonFormField<TipoIngreso>(
      value: _tipoIngreso,
      decoration: const InputDecoration(
        labelText: 'Tipo de ingreso',
        border: OutlineInputBorder(),
      ),
      items: TipoIngreso.values
          .map(
            (t) => DropdownMenuItem(
              value: t,
              child: Text(EtiquetasIngreso.labels[t] ?? t.name),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _tipoIngreso = v!),
    );
  }

  Widget _buildSelectorEgreso() {
    final subs = SubcategoriasGasto.obtener(_grupo);
    if (!subs.contains(_subcategoria)) {
      _subcategoria = subs.first;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<GrupoGasto>(
          value: _grupo,
          decoration: const InputDecoration(
            labelText: 'Categoría',
            border: OutlineInputBorder(),
          ),
          items: GrupoGasto.values
              .map(
                (g) => DropdownMenuItem(
                  value: g,
                  child: Text(EtiquetasGasto.labelGrupo(g)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _grupo = v!;
            _subcategoria = SubcategoriasGasto.obtener(_grupo).first;
          }),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _subcategoria,
          decoration: const InputDecoration(
            labelText: 'Subcategoría',
            border: OutlineInputBorder(),
          ),
          items: subs
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(EtiquetasGasto.label(s)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _subcategoria = v!),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    final montoVal = double.tryParse(_montoCtrl.text) ?? 0;
    if (montoVal <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido')));
      return;
    }

    final vm = ref.read(diagnosticoViewModelProvider.notifier);
    String? error;

    if (_tipo == 0) {
      final ingreso = Ingreso(
        id: widget.ingreso?.id ?? const Uuid().v4(),
        monto: Monto(montoVal),
        fecha: FechaFinanciera(_fecha),
        descripcion: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        tipo: _tipoIngreso,
      );
      error = widget.ingreso != null
          ? await vm.actualizarIngreso(ingreso)
          : await vm.agregarIngreso(ingreso);
    } else {
      final egreso = Egreso(
        id: widget.egreso?.id ?? const Uuid().v4(),
        monto: Monto(montoVal),
        fecha: FechaFinanciera(_fecha),
        descripcion: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        grupo: _grupo,
        subcategoria: _subcategoria,
        recurrente: false,
      );
      error = widget.egreso != null
          ? await vm.actualizarEgreso(egreso)
          : await vm.agregarEgreso(egreso);
    }

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final esEdicion = widget.ingreso != null || widget.egreso != null;
    if (!esEdicion) {
      final gamif = ref.read(gamificacionViewModelProvider.notifier);

      // 🎁 Logro de primera vez
      Logro? logro;
      if (_tipo == 0) {
        logro = await gamif.desbloquearLogro(CatalogoLogros.primerIngreso);
      } else {
        logro = await gamif.desbloquearLogro(CatalogoLogros.primerGasto);
      }
      if (logro != null && mounted) {
        await mostrarLogroPopup(context, logro);
      }

      // ➕ Puntos recurrentes
      await gamif.registrarAccion(_tipo == 0 ? 'ingreso' : 'gasto');
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
