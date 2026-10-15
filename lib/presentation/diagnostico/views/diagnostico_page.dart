import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/diagnostico_viewmodel.dart';
import 'package:fin_up_project/core/utils/formato_moneda.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';
import 'package:fin_up_project/presentation/shared/notificaciones_dialog.dart';
import 'package:fin_up_project/presentation/diagnostico/views/periodo_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'movimiento_form_page.dart';

class DiagnosticoPage extends ConsumerStatefulWidget {
  const DiagnosticoPage({super.key});

  @override
  ConsumerState<DiagnosticoPage> createState() => _DiagnosticoPageState();
}

class _DiagnosticoPageState extends ConsumerState<DiagnosticoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    Future.microtask(
      () => ref.read(diagnosticoViewModelProvider.notifier).cargarTodo(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosticoViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        actions: const [BotonProgramarNotificaciones()],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumen', icon: Icon(Icons.insights)),
            Tab(text: 'Ingresos', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'Gastos', icon: Icon(Icons.arrow_downward)),
          ],
        ),
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (data) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_animController.isAnimating) {
              _animController
                ..reset()
                ..forward();
            }
          });

          return TabBarView(
            controller: _tabController,
            children: [
              _buildResumen(data),
              _buildIngresos(data),
              _buildEgresos(data),
            ],
          );
        },
        error: (msg) => Center(child: Text('Error: $msg')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final r = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const MovimientoFormPage()),
          );
          if (r == true) {
            ref.read(diagnosticoViewModelProvider.notifier).cargarTodo();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildResumen(MovimientosData data) {
    final diag = data.diagnosticoActual;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Período actual ──
          Text(
            data.nombreMesActual,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Período actual',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hábito: ${diag.habito}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capacidad de ahorro: ${FormatoMoneda.pesos(diag.capacidadAhorro)}',
                  ),
                  Text(
                    'Ingresos: ${FormatoMoneda.pesos(diag.totalIngresos)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    'Egresos: ${FormatoMoneda.pesos(diag.totalEgresos)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Gráfico ──
          const Text(
            'Comparativa actual vs ideal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calcularMaxY(diag.actualPorGrupo, diag.idealPorGrupo),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                        '${ri == 0 ? "Actual" : "Ideal"}\n${FormatoMoneda.pesos(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          const labels = ['Nec', 'Entr', 'Ocio', 'Ahorro'];
                          if (v.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[v.toInt()],
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _grupo(
                      0,
                      (diag.actualPorGrupo['necesidad'] ?? 0) * _anim.value,
                      (diag.idealPorGrupo['necesidad'] ?? 0) * _anim.value,
                    ),
                    _grupo(
                      1,
                      (diag.actualPorGrupo['entretenimiento'] ?? 0) *
                          _anim.value,
                      (diag.idealPorGrupo['entretenimiento'] ?? 0) *
                          _anim.value,
                    ),
                    _grupo(
                      2,
                      (diag.actualPorGrupo['ocio'] ?? 0) * _anim.value,
                      (diag.idealPorGrupo['ocio'] ?? 0) * _anim.value,
                    ),
                    _grupo(
                      3,
                      (diag.actualPorGrupo['ahorro_deuda'] ?? 0) * _anim.value,
                      (diag.idealPorGrupo['ahorro_deuda'] ?? 0) * _anim.value,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Leyenda(color: Colors.red, texto: 'Actual'),
              SizedBox(width: 16),
              _Leyenda(color: Colors.green, texto: 'Ideal'),
            ],
          ),
          const SizedBox(height: 24),

          // ── Recomendaciones del período actual ──
          if (diag.recomendaciones.isNotEmpty) ...[
            const Text(
              'Recomendaciones del mes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...diag.recomendaciones.map(
              (r) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                  ),
                  title: Text('${r.grupo} · ${r.subcategoria}'),
                  subtitle: Text(
                    'Actual: ${FormatoMoneda.pesos(r.gastoActual)} → '
                    'Sugerido: ${FormatoMoneda.pesos(r.gastoSugerido)}\n${r.mensaje}',
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ahorro adicional esperado: ${FormatoMoneda.pesos(diag.ahorroAdicionalEsperado)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ── Período anterior (accionable) ──
          if (data.periodoAnterior != null) ...[
            const Text(
              'Mes anterior',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PeriodoCard(
              periodo: data.periodoAnterior!,
              onTap: () =>
                  mostrarDetallePeriodo(context, data.periodoAnterior!),
            ),
          ],

          const SizedBox(height: 16),
          const Text(
            '⚠️ Los resultados son orientativos y no constituyen asesoría financiera profesional.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIngresos(MovimientosData data) {
    final ingresos = data.ingresosActuales;
    if (ingresos.isEmpty) {
      return const Center(child: Text('Sin ingresos en este período.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ingresos.length,
      itemBuilder: (ctx, i) {
        final ing = ingresos[i];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.arrow_upward, color: Colors.white),
            ),
            title: Text(ing.tipo.name),
            subtitle: Text(
              '${ing.fecha.formatoCorto}${ing.descripcion != null ? ' · ${ing.descripcion}' : ''}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  FormatoMoneda.pesos(ing.monto.valor),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  onPressed: () async {
                    final r = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovimientoFormPage(ingreso: ing),
                      ),
                    );
                    if (r == true) {
                      ref
                          .read(diagnosticoViewModelProvider.notifier)
                          .cargarTodo();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _confirmarEliminarIngreso(ing.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEgresos(MovimientosData data) {
    final egresos = data.egresosActuales;
    if (egresos.isEmpty) {
      return const Center(child: Text('Sin gastos en este período.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: egresos.length,
      itemBuilder: (ctx, i) {
        final eg = egresos[i];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.arrow_downward, color: Colors.white, size: 18),
            ),
            title: Text(eg.subcategoria),
            subtitle: Text('${eg.grupo.name} · ${eg.fecha.formatoCorto}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  FormatoMoneda.pesos(eg.monto.valor),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  onPressed: () async {
                    final r = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovimientoFormPage(egreso: eg),
                      ),
                    );
                    if (r == true) {
                      ref
                          .read(diagnosticoViewModelProvider.notifier)
                          .cargarTodo();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _confirmarEliminarEgreso(eg.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarEliminarIngreso(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: const Text('¿Seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(diagnosticoViewModelProvider.notifier).eliminarIngreso(id);
    }
  }

  Future<void> _confirmarEliminarEgreso(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: const Text('¿Seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(diagnosticoViewModelProvider.notifier).eliminarEgreso(id);
    }
  }

  double _calcularMaxY(Map<String, double> a, Map<String, double> b) {
    double max = 0;
    a.forEach((_, v) {
      if (v > max) max = v;
    });
    b.forEach((_, v) {
      if (v > max) max = v;
    });
    return max == 0 ? 100 : max * 1.2;
  }

  BarChartGroupData _grupo(int x, double actual, double ideal) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: actual,
          color: Colors.red,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: ideal,
          color: Colors.green,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;
  const _Leyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }
}
