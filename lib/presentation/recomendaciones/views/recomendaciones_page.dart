import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/recomendaciones_viewmodel.dart';
import '/presentation/shared/base_view_model.dart';

class RecomendacionesPage extends ConsumerWidget {
  const RecomendacionesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recomendacionesViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendaciones')),
      body: state.when(
        initial: () => const Center(child: Text('Presiona para obtener recomendaciones')),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (recs) => ListView.builder(
          itemCount: recs.length,
          itemBuilder: (ctx, i) => ListTile(
            leading: Icon(recs[i].categoria == 'ahorro' ? Icons.savings : Icons.money_off),
            title: Text(recs[i].mensaje),
          ),
        ),
        error: (msg) => Center(child: Text('Error: $msg')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(recomendacionesViewModelProvider.notifier).cargarRecomendaciones(),
        child: const Icon(Icons.tips_and_updates),
      ),
    );
  }
}