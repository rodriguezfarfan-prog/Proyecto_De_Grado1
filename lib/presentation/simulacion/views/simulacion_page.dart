import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/simulacion_viewmodel.dart';
import '/domain/simulacion_compra/entities/datos_compra.dart';
import '/domain/simulacion_compra/entities/metodo_pago.dart';
import '/presentation/shared/base_view_model.dart';
import '/domain/simulacion_compra/entities/resultado_simulacion.dart';

class SimulacionPage extends ConsumerStatefulWidget {
  const SimulacionPage({super.key});

  @override
  ConsumerState<SimulacionPage> createState() => _SimulacionCompraPageState();
}

class _SimulacionCompraPageState extends ConsumerState<SimulacionPage> {
  final _precioCtrl       = TextEditingController();
  final _cuotaInicialCtrl = TextEditingController();
  final _plazoCtrl        = TextEditingController();
  final _tasaCtrl         = TextEditingController();
  TipoMetodoPago _metodoSeleccionado = TipoMetodoPago.contado;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simulacionCompraViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Compra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Precio del producto',
                style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Ej. 2500000'),
            ),
            const SizedBox(height: 12),

            // ── CORRECCIÓN: isExpanded + overflow en item largo ─────────
            DropdownButtonFormField<TipoMetodoPago>(
              value: _metodoSeleccionado,
              isExpanded: true, // evita el overflow horizontal
              items: const [
                DropdownMenuItem(
                  value: TipoMetodoPago.contado,
                  child: Text('Contado'),
                ),
                DropdownMenuItem(
                  value: TipoMetodoPago.tarjetaCredito,
                  child: Text('Tarjeta de crédito'),
                ),
                DropdownMenuItem(
                  value: TipoMetodoPago.creditoConsumo,
                  child: Text('Crédito de consumo'),
                ),
                DropdownMenuItem(
                  value: TipoMetodoPago.compraAhoraPagaDespues,
                  child: Text(
                    'Compra ahora, paga después (Addi/Sistecrédito)',
                    overflow: TextOverflow.ellipsis, // corta el texto si es muy largo
                  ),
                ),
                DropdownMenuItem(
                  value: TipoMetodoPago.prestamoInformal,
                  child: Text('Préstamo informal (familiar/amigo)'),
                ),
              ],
              onChanged: (v) => setState(() => _metodoSeleccionado = v!),
            ),
            // ────────────────────────────────────────────────────────────

            if (_metodoSeleccionado != TipoMetodoPago.contado) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _cuotaInicialCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Cuota inicial (opcional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _plazoCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Plazo en meses'),
              ),
            ],

            if (_metodoSeleccionado == TipoMetodoPago.tarjetaCredito ||
                _metodoSeleccionado == TipoMetodoPago.creditoConsumo ||
                _metodoSeleccionado ==
                    TipoMetodoPago.compraAhoraPagaDespues) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _tasaCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Tasa interés mensual (%) – opcional'),
              ),
            ],

            if (_metodoSeleccionado == TipoMetodoPago.prestamoInformal) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _tasaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Monto total a devolver (opcional)'),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.calculate),
              label: const Text('Calcular'),
              onPressed: () {
                final precio = double.tryParse(_precioCtrl.text) ?? 0;
                if (precio <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa un precio válido')),
                  );
                  return;
                }
                final datos = DatosCompra(
                  precioProducto: precio,
                  cuotaInicial:
                      double.tryParse(_cuotaInicialCtrl.text) ?? 0,
                  metodo: _metodoSeleccionado,
                  plazoMeses: int.tryParse(_plazoCtrl.text),
                  tasaInteresMensual:
                      double.tryParse(_tasaCtrl.text) != null
                          ? double.parse(_tasaCtrl.text) / 100
                          : null,
                  montoTotalDevolver:
                      _metodoSeleccionado == TipoMetodoPago.prestamoInformal
                          ? double.tryParse(_tasaCtrl.text)
                          : null,
                );
                ref
                    .read(simulacionCompraViewModelProvider.notifier)
                    .calcular(datos);
              },
            ),

            const SizedBox(height: 24),
            state.when(
              initial: () => const SizedBox.shrink(),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              data: (resultado) =>
                  _ResultadoWidget(resultado: resultado),
              error: (msg) => Text('Error: $msg',
                  style: const TextStyle(color: Colors.red)),
            ),

            const SizedBox(height: 16),
            const Text(
              '⚠️ Los resultados son orientativos y no constituyen asesoría financiera profesional.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultadoWidget extends StatelessWidget {
  final ResultadoSimulacion resultado;
  const _ResultadoWidget({required this.resultado});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Cuota mensual: \$${resultado.cuotaMensual.toStringAsFixed(0)}'),
        Text('Costo total: \$${resultado.costoTotal.toStringAsFixed(0)}'),
        Text(
          resultado.mensaje,
          style: TextStyle(
              color: resultado.esViable ? Colors.green : Colors.red),
        ),
        if (resultado.recomendacion != null) ...[
          const SizedBox(height: 8),
          Text('💡 ${resultado.recomendacion}'),
        ],
      ],
    );
  }
}