import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/diagnostico')) return 1;
    if (location.startsWith('/simulacion')) return 2;
    if (location.startsWith('/ahorro')) return 3;
    if (location.startsWith('/recomendaciones')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/diagnostico');
        break;
      case 2:
        context.go('/simulacion');
        break;
      case 3:
        context.go('/ahorro');
        break;
      case 4:
        context.go('/recomendaciones');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Diagnóstico'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'Simulación'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Ahorro'),
          BottomNavigationBarItem(icon: Icon(Icons.tips_and_updates), label: 'Tips'),
        ],
      ),
    );
  }
}