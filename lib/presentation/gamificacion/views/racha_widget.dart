import 'package:flutter/material.dart';

class RachaWidget extends StatelessWidget {
  final int racha;

  const RachaWidget({super.key, required this.racha});

  @override
  Widget build(BuildContext context) {
    // Colores según la intensidad de la racha
    Color color;
    if (racha >= 30) {
      color = const Color(0xFFD32F2F); // rojo intenso
    } else if (racha >= 7) {
      color = const Color(0xFFFF6D00); // naranja fuego
    } else if (racha >= 3) {
      color = const Color(0xFFFF9800); // naranja
    } else {
      color = const Color(0xFFFFC107); // ámbar
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: 20, color: color)),
          const SizedBox(width: 4),
          Text(
            '$racha',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
