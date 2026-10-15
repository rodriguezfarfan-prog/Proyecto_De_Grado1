import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fin_up_project/domain/gamificacion/entities/perfil_gamificacion.dart';

class CirculoNivel extends StatelessWidget {
  final PerfilGamificacion perfil;

  const CirculoNivel({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    final inicial = perfil.nombre.isNotEmpty
        ? perfil.nombre.substring(0, 1).toUpperCase()
        : '?';

    return Column(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(160, 160),
                painter: _ProgresoPainter(progreso: perfil.progreso),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Nivel ${perfil.nivel}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${perfil.puntosEnNivel}/${PerfilGamificacion.puntosPorNivel} pts',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          '${perfil.puntos} puntos en total',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _ProgresoPainter extends CustomPainter {
  final double progreso;
  _ProgresoPainter({required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = size.width / 2 - 4;
    final grosor = 8.0;

    final fondoPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(centro, radio, fondoPaint);

    final progresoPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;

    const inicio = -math.pi / 2;
    final barrido = 2 * math.pi * progreso;
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: radio),
      inicio,
      barrido,
      false,
      progresoPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgresoPainter oldDelegate) =>
      oldDelegate.progreso != progreso;
}
