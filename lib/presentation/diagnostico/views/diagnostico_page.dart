import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/diagnostico_viewmodel.dart';
import '/domain/diagnostico/entities/egreso.dart';
import '/presentation/shared/base_view_model.dart';

class DiagnosticoPage extends ConsumerStatefulWidget {
  const DiagnosticoPage({super.key});

  @override
  ConsumerState<DiagnosticoPage> createState() => _DiagnosticoPageState();
}

class _DiagnosticoPageState extends ConsumerState<DiagnosticoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;
  int _touchedBarGroup = -1;

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
      () => ref.read(diagnosticoViewModelProvider.notifier).cargarDiagnostico(),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _animController.reset();
    await ref.read(diagnosticoViewModelProvider.notifier).cargarDiagnostico();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosticoViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Financiero'),
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
          data: (completo) {
            // Disparar animación cuando llegan los datos
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_animController.isAnimating &&
                  _animController.status != AnimationStatus.completed) {
                _animController.forward();
              }
            });

            final d = completo.diagnostico;
            final comparativa = completo.comparativa;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hábito financiero ─────────────────────────────────
                  _HabitoBadge(habito: d.habito),
                  const SizedBox(height: 24),

                  // ── Capacidad de ahorro ───────────────────────────────
                  _SavingCard(capacidadAhorro: d.capacidadAhorro),
                  const SizedBox(height: 20),

                  // ── Recomendaciones ───────────────────────────────────
                  if (d.recomendacionesBasicas.isNotEmpty) ...[
                    const Text(
                      'Recomendaciones',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...d.recomendacionesBasicas.map(
                      (rec) => _RecomendacionItem(texto: rec),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Comparativa actual vs ideal ───────────────────────
                  if (comparativa != null) ...[
                    const Text(
                      'Distribución de gastos: actual vs ideal',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const _ChartLegend(),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (context, _) => _ComparativaChart(
                        actual: comparativa.actual,
                        ideal: comparativa.ideal,
                        animValue: _anim.value,
                        touchedGroupIndex: _touchedBarGroup,
                        onTouch: (i) => setState(() => _touchedBarGroup = i),
                      ),
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
// GRÁFICO COMPARATIVO (BARRAS) — actual vs ideal por categoría
// ─────────────────────────────────────────────────────────────────────────────
class _ComparativaChart extends StatelessWidget {
  final Map<CategoriaEgreso, double> actual;
  final Map<CategoriaEgreso, double> ideal;
  final double animValue;
  final int touchedGroupIndex;
  final ValueChanged<int> onTouch;

  const _ComparativaChart({
    required this.actual,
    required this.ideal,
    required this.animValue,
    required this.touchedGroupIndex,
    required this.onTouch,
  });

  static const _colorActual = Color(0xFFF44336);
  static const _colorIdeal = Color(0xFF4CAF50);

  List<CategoriaEgreso> get _categorias {
    final keys = <CategoriaEgreso>{...actual.keys, ...ideal.keys}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    final categorias = _categorias;
    if (categorias.isEmpty) return const SizedBox(height: 220);

    final rawMax = [...actual.values, ...ideal.values]
        .fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = rawMax == 0 ? 10.0 : rawMax * 1.2;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        height: 260,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            groupsSpace: 20,
            barTouchData: BarTouchData(
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.spot == null) {
                  onTouch(-1);
                  return;
                }
                onTouch(response.spot!.touchedBarGroupIndex);
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final cat = categorias[group.x.toInt()];
                  final label = rodIndex == 0 ? 'Actual' : 'Ideal';
                  return BarTooltipItem(
                    '${_categoryLabel(cat)}\n$label: ${_fmt(rod.toY)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    _fmt(value),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= categorias.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: -0.45,
                        child: Text(
                          _categoryLabel(categorias[index]),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(categorias.length, (index) {
              final cat = categorias[index];
              final a = (actual[cat] ?? 0) * animValue;
              final i = (ideal[cat] ?? 0) * animValue;
              final isTouched = touchedGroupIndex == index;

              return BarChartGroupData(
                x: index,
                barsSpace: 6,
                barRods: [
                  BarChartRodData(
                    toY: a,
                    color: _colorActual,
                    width: isTouched ? 16 : 12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                  BarChartRodData(
                    toY: i,
                    color: _colorIdeal,
                    width: isTouched ? 16 : 12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // Convierte el nombre del enum (ej: 'serviciosBasicos' o 'gastos_varios')
  // en un texto legible ('Servicios Basicos', 'Gastos Varios'). Funciona con
  // cualquier convención de nombres del enum, sin necesitar conocer sus
  // valores exactos. Si quieres nombres personalizados con tildes, reemplaza
  // esta función por un switch(cat), igual que se hace en _HabitoBadge.
  static String _categoryLabel(CategoriaEgreso cat) {
    final raw = cat.name;
    final withSpaces = raw
        .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ');
    return withSpaces
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  static String _fmt(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(0)}K';
    return '\$${v.toStringAsFixed(0)}';
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendDot(color: Color(0xFFF44336), label: 'Actual'),
        SizedBox(width: 16),
        _LegendDot(color: Color(0xFF4CAF50), label: 'Ideal'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA CAPACIDAD DE AHORRO
// ─────────────────────────────────────────────────────────────────────────────
class _SavingCard extends StatelessWidget {
  final double capacidadAhorro;
  const _SavingCard({required this.capacidadAhorro});

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
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
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
      'Excelente': (const Color(0xFF4CAF50), Icons.star_rounded),
      'Bueno': (const Color(0xFF2196F3), Icons.thumb_up_rounded),
      'Ajustado': (const Color(0xFFFFC107), Icons.warning_rounded),
      'Deficitario': (const Color(0xFFF44336), Icons.trending_down_rounded),
    };
    final entry = config[habito] ?? (Colors.grey, Icons.help_outline);
    final color = (entry.$1 as Color);
    final icon = (entry.$2 as IconData);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text('Hábito financiero: ', style: Theme.of(context).textTheme.bodyMedium),
        Text(
          habito,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
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
          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFFC107), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
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