import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/gamificacion_viewmodel.dart';
import 'circulo_nivel.dart';
import 'package:fin_up_project/domain/gamificacion/entities/logro.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';

class PerfilPage extends ConsumerStatefulWidget {
  const PerfilPage({super.key});

  @override
  ConsumerState<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends ConsumerState<PerfilPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(gamificacionViewModelProvider.notifier).cargarPerfil(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gamificacionViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (perfil) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CirculoNivel(perfil: perfil),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Logros (${perfil.logrosDesbloqueados.length}/${CatalogoLogros.todos.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: CatalogoLogros.todos.length,
                itemBuilder: (context, i) {
                  final logro = CatalogoLogros.todos[i];
                  final desbloqueado = perfil.logrosDesbloqueados.contains(
                    logro.id,
                  );
                  return _LogroTile(logro: logro, desbloqueado: desbloqueado);
                },
              ),
            ],
          ),
        ),
        error: (msg) => Center(child: Text('Error: $msg')),
      ),
    );
  }
}

class _LogroTile extends StatelessWidget {
  final Logro logro;
  final bool desbloqueado;
  const _LogroTile({required this.logro, required this.desbloqueado});

  @override
  Widget build(BuildContext context) {
    final color = desbloqueado ? Colors.teal : Colors.grey.shade400;
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(desbloqueado ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            desbloqueado ? logro.icono : '🔒',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 6),
          Text(
            logro.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: desbloqueado ? Colors.black87 : Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
