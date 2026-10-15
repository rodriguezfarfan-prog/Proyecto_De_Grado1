import 'package:equatable/equatable.dart';

class PerfilGamificacion extends Equatable {
  final String usuarioId;
  final String nombre;
  final int puntos;
  final List<String> logrosDesbloqueados;
  final int rachaActual;
  final DateTime? ultimaVisita;

  const PerfilGamificacion({
    required this.usuarioId,
    required this.nombre,
    required this.puntos,
    required this.logrosDesbloqueados,
    this.rachaActual = 0,
    this.ultimaVisita,
  });

  static const int puntosPorNivel = 100;
  static const int maxNivel = 50;

  int get nivel {
    final n = (puntos ~/ puntosPorNivel) + 1;
    return n > maxNivel ? maxNivel : n;
  }

  int get puntosEnNivel {
    if (nivel >= maxNivel) return puntosPorNivel;
    return puntos % puntosPorNivel;
  }

  double get progreso {
    if (nivel >= maxNivel) return 1.0;
    return puntosEnNivel / puntosPorNivel;
  }

  int get puntosParaSiguienteNivel => puntosPorNivel;

  @override
  List<Object?> get props => [
    usuarioId,
    nombre,
    puntos,
    logrosDesbloqueados,
    rachaActual,
    ultimaVisita,
  ];
}
