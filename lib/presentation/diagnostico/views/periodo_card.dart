import 'package:flutter/material.dart';
import 'package:fin_up_project/core/utils/formato_moneda.dart';
import 'package:fin_up_project/domain/diagnostico/entities/periodo_financiero.dart';

class PeriodoCard extends StatelessWidget {
  final PeriodoFinanciero periodo;
  final VoidCallback onTap;

  const PeriodoCard({super.key, required this.periodo, required this.onTap});

  Color _colorHabito(String h) {
    switch (h) {
      case 'Excelente':
        return const Color(0xFF4CAF50);
      case 'Bueno':
        return const Color(0xFF2196F3);
      case 'Ajustado':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final diag = periodo.diagnostico;
    final color = _colorHabito(diag.habito);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    periodo.nombreMes,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Hábito: ${diag.habito}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Dato(
                    label: 'Ingresos',
                    valor: diag.totalIngresos,
                    color: Colors.green,
                  ),
                  _Dato(
                    label: 'Egresos',
                    valor: diag.totalEgresos,
                    color: Colors.red,
                  ),
                  _Dato(
                    label: 'Ahorro',
                    valor: diag.capacidadAhorro,
                    color: Colors.teal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String label;
  final double valor;
  final Color color;
  const _Dato({required this.label, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          FormatoMoneda.pesos(valor),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

void mostrarDetallePeriodo(BuildContext context, PeriodoFinanciero periodo) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollCtrl) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: scrollCtrl,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              periodo.nombreMes,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Hábito: ${periodo.diagnostico.habito}',
              style: const TextStyle(fontSize: 15),
            ),
            const Divider(height: 24),
            _FilaInfo(
              'Ingresos',
              FormatoMoneda.pesos(periodo.diagnostico.totalIngresos),
            ),
            _FilaInfo(
              'Egresos',
              FormatoMoneda.pesos(periodo.diagnostico.totalEgresos),
            ),
            _FilaInfo(
              'Capacidad de ahorro',
              FormatoMoneda.pesos(periodo.diagnostico.capacidadAhorro),
              bold: true,
            ),
            _FilaInfo(
              'Porcentaje de ahorro',
              '${periodo.diagnostico.porcentajeAhorro.toStringAsFixed(1)}%',
            ),
            const Divider(height: 24),
            const Text(
              'Gastos por grupo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _FilaInfo(
              'Necesidades',
              FormatoMoneda.pesos(
                periodo.diagnostico.actualPorGrupo['necesidad'] ?? 0,
              ),
            ),
            _FilaInfo(
              'Entretenimiento',
              FormatoMoneda.pesos(
                periodo.diagnostico.actualPorGrupo['entretenimiento'] ?? 0,
              ),
            ),
            _FilaInfo(
              'Ocio',
              FormatoMoneda.pesos(
                periodo.diagnostico.actualPorGrupo['ocio'] ?? 0,
              ),
            ),
            _FilaInfo(
              'Ahorro / Deuda',
              FormatoMoneda.pesos(
                periodo.diagnostico.actualPorGrupo['ahorro_deuda'] ?? 0,
              ),
            ),
            const Divider(height: 24),
            if (periodo.diagnostico.recomendaciones.isEmpty)
              const Text(
                'Sin recomendaciones para este período.',
                style: TextStyle(color: Colors.grey),
              )
            else ...[
              const Text(
                'Recomendaciones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...periodo.diagnostico.recomendaciones.map(
                (r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange,
                    ),
                    title: Text('${r.grupo} · ${r.subcategoria}'),
                    subtitle: Text(
                      'Actual: ${FormatoMoneda.pesos(r.gastoActual)} → '
                      'Sugerido: ${FormatoMoneda.pesos(r.gastoSugerido)}\n${r.mensaje}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Ahorro adicional esperado: ${FormatoMoneda.pesos(periodo.diagnostico.ahorroAdicionalEsperado)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _FilaInfo extends StatelessWidget {
  final String label;
  final String valor;
  final bool bold;
  const _FilaInfo(this.label, this.valor, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            valor,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 15 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
