import 'package:equatable/equatable.dart';

class Logro extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final int puntos;
  final String icono;

  const Logro({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.puntos,
    required this.icono,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, puntos, icono];
}

/// Catálogo de logros disponibles
class CatalogoLogros {
  static const primerRegistro = Logro(
    id: 'primer_registro',
    nombre: '¡Bienvenido a FinUp!',
    descripcion: 'Creaste tu cuenta exitosamente',
    puntos: 50,
    icono: '🎉',
  );

  static const primerIngreso = Logro(
    id: 'primer_ingreso',
    nombre: 'Primer ingreso registrado',
    descripcion: 'Registraste tu primer ingreso',
    puntos: 20,
    icono: '💰',
  );

  static const primerGasto = Logro(
    id: 'primer_gasto',
    nombre: 'Primer gasto registrado',
    descripcion: 'Registraste tu primer gasto',
    puntos: 20,
    icono: '📝',
  );

  static const primeraMeta = Logro(
    id: 'primera_meta',
    nombre: 'Soñador con propósito',
    descripcion: 'Creaste tu primera meta de ahorro',
    puntos: 30,
    icono: '🎯',
  );

  static const primerAbono = Logro(
    id: 'primer_abono',
    nombre: 'Ahorrador en marcha',
    descripcion: 'Hiciste tu primer abono a una meta',
    puntos: 30,
    icono: '🏆',
  );

  static const primerCalculo = Logro(
    id: 'primer_calculo',
    nombre: 'Analista financiero',
    descripcion: 'Usaste la calculadora por primera vez',
    puntos: 10,
    icono: '🧮',
  );

  static const todos = <Logro>[
    primerRegistro,
    primerIngreso,
    primerGasto,
    primeraMeta,
    primerAbono,
    primerCalculo,
  ];

  static Logro? porId(String id) {
    try {
      return todos.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
