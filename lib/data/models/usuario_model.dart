import '/domain/usuario/entities/usuario.dart';

class UsuarioModel {
  final String id;
  final String nombre;
  final String email;
  final String fechaRegistro;
  final String nivelFinanciero;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.fechaRegistro,
    required this.nivelFinanciero,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      fechaRegistro: json['fecha_registro'],
      nivelFinanciero: json['nivel_financiero'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'fecha_registro': fechaRegistro,
    'nivel_financiero': nivelFinanciero,
  };

  Usuario toDomain() => Usuario(
    id: id,
    nombre: nombre,
    email: email,
    fechaRegistro: DateTime.parse(fechaRegistro),
    nivelFinanciero: NivelFinanciero.values.firstWhere(
      (e) => e.name == nivelFinanciero,
    ),
  );
}