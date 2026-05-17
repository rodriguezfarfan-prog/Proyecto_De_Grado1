enum NivelFinanciero { principiante, intermedio, avanzado }

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final DateTime fechaRegistro;
  final NivelFinanciero nivelFinanciero;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.fechaRegistro,
    required this.nivelFinanciero,
  });
}