import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/ahorro_viewmodel.dart';
import '/presentation/shared/base_view_model.dart';

class AhorroPage extends ConsumerWidget {
  const AhorroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ahorroViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plan de Ahorro')),
      body: state.when(
        initial: () => const Center(child: Text('Ingresa el ID de tu meta para calcular')),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (plan) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ahorro mensual necesario: \$${plan.montoMensualRequerido.toStringAsFixed(2)}'),
              Text('Meses restantes: ${plan.mesesRestantes}'),
              Text('Porcentaje del ingreso: ${plan.porcentajeIngreso.toStringAsFixed(1)}%'),
            ],
          ),
        ),
        error: (msg) => Center(child: Text('Error: $msg')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TextField para el ID de la meta (simplificado)
          // En una app real, seleccionarías de una lista
          FloatingActionButton(
            heroTag: 'calc',
            onPressed: () {
              // Aquí deberías obtener el ID de la meta (hardcodeado para probar)
              const metaId = 'ID_DE_TU_META';
              ref.read(ahorroViewModelProvider.notifier).calcularPlan(metaId);
            },
            child: const Icon(Icons.calculate),
          ),
        ],
      ),
    );
  }
}