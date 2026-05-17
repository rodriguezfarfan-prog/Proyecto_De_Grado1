import 'package:go_router/go_router.dart';
import '/presentation/diagnostico/views/diagnostico_page.dart';
import '/presentation/simulacion/views/simulacion_page.dart';
import '/presentation/ahorro/views/ahorro_page.dart';
import '/presentation/dashboard/views/dashboard_page.dart';
import '/presentation/recomendaciones/views/recomendaciones_page.dart';
import '/presentation/shared/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/diagnostico', builder: (_, __) => const DiagnosticoPage()),
        GoRoute(path: '/simulacion', builder: (_, __) => const SimulacionPage()),
        GoRoute(path: '/ahorro', builder: (_, __) => const AhorroPage()),
        GoRoute(path: '/recomendaciones', builder: (_, __) => const RecomendacionesPage()),
      ],
    ),
  ],
);