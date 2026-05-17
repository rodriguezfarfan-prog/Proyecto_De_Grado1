import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/diagnostico_viewmodel.dart';
import '/presentation/shared/base_view_model.dart';

class DiagnosticoPage extends ConsumerWidget {
  const DiagnosticoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagnosticoViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico Financiero')),
      body: state.when(
        initial: () => const Center(child: Text('Presiona el botón para comenzar')),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (diag) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Capacidad de ahorro: \$${diag.capacidadAhorro.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text('Hábito: ${diag.habito}'),
              const SizedBox(height: 16),
              const Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...diag.recomendacionesBasicas.map((r) => ListTile(leading: const Icon(Icons.lightbulb), title: Text(r))),
            ],
          ),
        ),
        error: (msg) => Center(child: Text('Error: $msg', style: const TextStyle(color: Colors.red))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(diagnosticoViewModelProvider.notifier).cargarDiagnostico(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}