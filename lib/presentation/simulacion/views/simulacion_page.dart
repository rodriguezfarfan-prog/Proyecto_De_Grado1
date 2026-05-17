import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/simulacion_viewmodel.dart';
import '/domain/diagnostico/entities/egreso.dart';
import '/presentation/shared/base_view_model.dart';

class SimulacionPage extends ConsumerWidget {
  const SimulacionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulacionViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Simulación de Gastos')),
      body: state.when(
        initial: () => const Center(child: Text('Presiona para simular')),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (comparativa) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Distribución actual vs ideal', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: _buildGroups(comparativa.actual, comparativa.ideal),
                    titlesData: FlTitlesData(show: true),
                  ),
                ),
              ),
            ],
          ),
        ),
        error: (msg) => Center(child: Text('Error: $msg')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(simulacionViewModelProvider.notifier).cargarSimulacion(),
        child: const Icon(Icons.auto_graph),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups(Map<CategoriaEgreso, double> actual, Map<CategoriaEgreso, double> ideal) {
    // Simplificado: grafica dos barras por categoría
    return actual.keys.map((cat) {
      final a = actual[cat] ?? 0;
      final i = ideal[cat] ?? 0;
      return BarChartGroupData(
        x: cat.index,
        barRods: [
          BarChartRodData(toY: a, color: Colors.blue),
          BarChartRodData(toY: i, color: Colors.green),
        ],
      );
    }).toList();
  }
}