import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '/presentation/shared/base_view_model.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);

    // Carga automática al abrir la pantalla
    Future.microtask(
      () => ref.read(dashboardViewModelProvider.notifier).cargarDashboard(),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _animController.reset();
    await ref.read(dashboardViewModelProvider.notifier).cargarDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Financiero'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: state.when(
          initial: () => const _CenteredScrollable(
            child: CircularProgressIndicator(),
          ),
          loading: () => const _CenteredScrollable(
            child: CircularProgressIndicator(),
          ),
          data: (data) {
            // Disparar animación cuando llegan los datos
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_animController.isAnimating &&
                  _animController.status != AnimationStatus.completed) {
                _animController.forward();
              }
            });

            final d = data.diagnostico; // DiagnosticoResultado

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hábito financiero ─────────────────────────────────
                  _HabitoBadge(habito: d.habito),
                  const SizedBox(height: 24),

                  // ── Gráfico donut animado ─────────────────────────────
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (context, _) => _DonutChart(
                      totalIngresos: d.totalIngresos,
                      totalEgresos: d.totalEgresos,
                      capacidadAhorro: d.capacidadAhorro,
                      porcentajeAhorro: d.porcentajeAhorro,
                      animValue: _anim.value,
                      touchedIndex: _touchedIndex,
                      onTouch: (i) => setState(() => _touchedIndex = i),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Tarjetas ingresos / egresos / ahorro ──────────────
                  _MetricRow(
                    totalIngresos: d.totalIngresos,
                    totalEgresos: d.totalEgresos,
                    capacidadAhorro: d.capacidadAhorro,
                  ),
                  const SizedBox(height: 16),

                  // ── Capacidad de ahorro detallada ─────────────────────
                  _SavingCard(
                    capacidadAhorro: d.capacidadAhorro,
                    porcentajeAhorro: d.porcentajeAhorro,
                  ),
                  const SizedBox(height: 20),

                  // ── Recomendaciones básicas ───────────────────────────
                  if (d.recomendacionesBasicas.isNotEmpty) ...[
                    const Text(
                      'Recomendaciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...d.recomendacionesBasicas.map(
                      (rec) => _RecomendacionItem(texto: rec),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
          error: (msg) => _CenteredScrollable(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Error: $msg',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRÁFICO DONUT
// ─────────────────────────────────────────────────────────────────────────────
class _DonutChart extends StatelessWidget {
  final double totalIngresos;
  final double totalEgresos;
  final double capacidadAhorro;
  final double porcentajeAhorro;
  final double animValue;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _DonutChart({
    required this.totalIngresos,
    required this.totalEgresos,
    required this.capacidadAhorro,
    required this.porcentajeAhorro,
    required this.animValue,
    required this.touchedIndex,
    required this.onTouch,
  });

  static const _colorIngreso = Color(0xFF4CAF50);
  static const _colorEgreso  = Color(0xFFF44336);
  static const _colorAhorro  = Color(0xFF2196F3);

  Color get _habitoColor {
    if (porcentajeAhorro >= 20) return _colorIngreso;
    if (porcentajeAhorro >= 10) return const Color(0xFF2196F3);
    if (porcentajeAhorro >= 0)  return const Color(0xFFFFC107);
    return _colorEgreso;
  }

  @override
  Widget build(BuildContext context) {
    final ahorro = capacidadAhorro.clamp(0.0, double.infinity);
    final total  = totalIngresos + totalEgresos + ahorro;
    if (total == 0) return const SizedBox(height: 240);

    final sections = [
      PieChartSectionData(
        value: totalIngresos * animValue,
        color: _colorIngreso,
        radius: touchedIndex == 0 ? 54 : 46,
        title: touchedIndex == 0 ? _fmt(totalIngresos) : '',
        titleStyle: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: totalEgresos * animValue,
        color: _colorEgreso,
        radius: touchedIndex == 1 ? 54 : 46,
        title: touchedIndex == 1 ? _fmt(totalEgresos) : '',
        titleStyle: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: ahorro * animValue,
        color: _colorAhorro,
        radius: touchedIndex == 2 ? 54 : 46,
        title: touchedIndex == 2 ? _fmt(ahorro) : '',
        titleStyle: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
        ),
      ),
    ];

    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: animValue < 0.99 ? 0 : 3,
              centerSpaceRadius: 72,
              sections: sections,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response?.touchedSection == null) {
                    onTouch(-1);
                    return;
                  }
                  onTouch(response!.touchedSection!.touchedSectionIndex);
                },
              ),
            ),
          ),
          // Texto central animado
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(porcentajeAhorro * animValue).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _habitoColor,
                ),
              ),
              const Text(
                'de ahorro',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '\$${(v / 1000).toStringAsFixed(0)}K';
    return '\$${v.toStringAsFixed(0)}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILA DE MÉTRICAS
// ─────────────────────────────────────────────────────────────────────────────
class _MetricRow extends StatelessWidget {
  final double totalIngresos;
  final double totalEgresos;
  final double capacidadAhorro;

  const _MetricRow({
    required this.totalIngresos,
    required this.totalEgresos,
    required this.capacidadAhorro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Ingresos',
            amount: totalIngresos,
            icon: Icons.arrow_downward_rounded,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Egresos',
            amount: totalEgresos,
            icon: Icons.arrow_upward_rounded,
            color: const Color(0xFFF44336),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Ahorro',
            amount: capacidadAhorro.clamp(0, double.infinity),
            icon: Icons.savings_rounded,
            color: const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            _fmt(amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '\$${(v / 1000).toStringAsFixed(0)}K';
    return '\$${v.toStringAsFixed(0)}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA CAPACIDAD DE AHORRO
// ─────────────────────────────────────────────────────────────────────────────
class _SavingCard extends StatelessWidget {
  final double capacidadAhorro;
  final double porcentajeAhorro;

  const _SavingCard({
    required this.capacidadAhorro,
    required this.porcentajeAhorro,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = capacidadAhorro >= 0;
    final color = isPositive ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Capacidad de ahorro mensual',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${capacidadAhorro.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${porcentajeAhorro.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGE HÁBITO
// ─────────────────────────────────────────────────────────────────────────────
class _HabitoBadge extends StatelessWidget {
  final String habito;
  const _HabitoBadge({required this.habito});

  @override
  Widget build(BuildContext context) {
    final config = {
      'Excelente':  (const Color(0xFF4CAF50), Icons.star_rounded),
      'Bueno':      (const Color(0xFF2196F3), Icons.thumb_up_rounded),
      'Ajustado':   (const Color(0xFFFFC107), Icons.warning_rounded),
      'Deficitario':(const Color(0xFFF44336), Icons.trending_down_rounded),
    };
    final entry = config[habito] ?? (Colors.grey, Icons.help_outline);
    final color = (entry.$1 as Color);
    final icon  = (entry.$2 as IconData);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          'Hábito financiero: ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          habito,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ITEM DE RECOMENDACIÓN
// ─────────────────────────────────────────────────────────────────────────────
class _RecomendacionItem extends StatelessWidget {
  final String texto;
  const _RecomendacionItem({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: Color(0xFFFFC107), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: scroll para loading/error (necesario para el RefreshIndicator)
// ─────────────────────────────────────────────────────────────────────────────
class _CenteredScrollable extends StatelessWidget {
  final Widget child;
  const _CenteredScrollable({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Center(child: child),
      ),
    );
  }
}