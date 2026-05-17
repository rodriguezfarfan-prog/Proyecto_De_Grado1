import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '/presentation/shared/base_view_model.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Financiero')),
      body: state.when(
        initial: () => const Center(child: Text('Cargando resumen...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hábito: ${data.diagnostico.habito}'),
              Text('Capacidad de ahorro: \$${data.diagnostico.capacidadAhorro.toStringAsFixed(2)}'),
              const Divider(),
              Text('Comparativa de gastos (actual vs ideal)'),
              // Aquí podrías reutilizar un gráfico
            ],
          ),
        ),
        error: (msg) => Center(child: Text('Error: $msg')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(dashboardViewModelProvider.notifier).cargarDashboard(),
        child: const Icon(Icons.dashboard),
      ),
    );
  }
}