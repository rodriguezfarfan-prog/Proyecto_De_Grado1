class NotificacionConfig {
  final int id;
  final String titulo;
  final String descripcion;
  final String frecuencia; // 'mensual' | 'quincenal'
  final int dia; // 1-31 para mensual, 1 o 15 para quincenal
  final int hora;
  final int minuto;

  NotificacionConfig({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.frecuencia,
    required this.dia,
    required this.hora,
    required this.minuto,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'frecuencia': frecuencia,
    'dia': dia,
    'hora': hora,
    'minuto': minuto,
  };

  factory NotificacionConfig.fromJson(Map<String, dynamic> json) =>
      NotificacionConfig(
        id: json['id'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        frecuencia: json['frecuencia'],
        dia: json['dia'],
        hora: json['hora'],
        minuto: json['minuto'],
      );
}
