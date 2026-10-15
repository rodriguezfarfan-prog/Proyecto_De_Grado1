import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:fin_up_project/core/session/session_provider.dart';
import 'package:fin_up_project/domain/usuario/entities/usuario.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';
import 'package:fin_up_project/presentation/gamificacion/viewmodels/gamificacion_viewmodel.dart';
import 'package:fin_up_project/presentation/gamificacion/views/logro_popup.dart';
import 'package:fin_up_project/domain/gamificacion/entities/logro.dart';

class RegistroPage extends ConsumerStatefulWidget {
  const RegistroPage({super.key});

  @override
  ConsumerState<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends ConsumerState<RegistroPage> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePassword = true;

  String? _validarPassword(String password) {
    if (password.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'Falta una mayúscula';
    if (!password.contains(RegExp(r'[a-z]'))) return 'Falta una minúscula';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Falta un número';
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Falta un carácter especial';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    // Auto-login + logro de primer registro
    ref.listen<BaseState<Usuario>>(authViewModelProvider, (
      previous,
      next,
    ) async {
      if (next is Data<Usuario>) {
        print('📝 Registro exitoso, desbloqueando logro...');
        final usuario = next.value;
        ref.read(sessionProvider.notifier).login(usuario.id, usuario.nombre);

        // 🎮 Desbloquear logro de primer registro
        final gamif = ref.read(gamificacionViewModelProvider.notifier);
        final logro = await gamif.desbloquearLogro(
          CatalogoLogros.primerRegistro,
        );
        print('🎁 Logro obtenido: $logro');

        if (logro != null && mounted) {
          await mostrarLogroPopup(context, logro);
        }

        if (mounted) context.go('/dashboard');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPassCtrl,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  final nombre = _nombreCtrl.text.trim();
                  final email = _emailCtrl.text.trim();
                  final pass = _passCtrl.text;
                  final confirm = _confirmPassCtrl.text;

                  if (nombre.isEmpty || email.isEmpty || pass.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos'),
                      ),
                    );
                    return;
                  }
                  if (pass != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Las contraseñas no coinciden'),
                      ),
                    );
                    return;
                  }

                  final errorPass = _validarPassword(pass);
                  if (errorPass != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Contraseña: $errorPass')),
                    );
                    return;
                  }

                  ref
                      .read(authViewModelProvider.notifier)
                      .registrarse(nombre, email, pass);
                },
                child: const Text(
                  'Registrarse',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
      ),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }
}
