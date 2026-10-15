import 'package:fin_up_project/presentation/ahorro/views/crear_meta_page.dart';
import 'package:go_router/go_router.dart';
import '/presentation/auth/views/login_page.dart';
import '/presentation/auth/views/registro_page.dart';
import '/presentation/diagnostico/views/diagnostico_page.dart';
import '/presentation/simulacion/views/simulacion_page.dart';
import '/presentation/ahorro/views/ahorro_page.dart';
import '/presentation/dashboard/views/dashboard_page.dart';
import '/presentation/recomendaciones/views/recomendaciones_page.dart';
import '/presentation/shared/app_shell.dart';
import '/presentation/perfil/views/configuration_page.dart';
import 'package:fin_up_project/presentation/gamificacion/views/perfil_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/registro', builder: (_, __) => const RegistroPage()),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
        GoRoute(
          path: '/diagnostico',
          builder: (_, __) => const DiagnosticoPage(),
        ),
        GoRoute(
          path: '/simulacion',
          builder: (_, __) => const SimulacionPage(),
        ),
        GoRoute(path: '/ahorro', builder: (_, __) => const AhorroPage()),
        GoRoute(path: '/crear-meta', builder: (_, __) => const CrearMetaPage()),
        GoRoute(path: '/perfil', builder: (_, __) => const PerfilPage()),
      ],
    ),
  ],
);
