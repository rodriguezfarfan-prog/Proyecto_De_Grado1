import 'package:fin_up_project/core/value_objects/monto.dart';
import 'package:fin_up_project/core/value_objects/fecha.dart';
import 'package:equatable/equatable.dart';

enum GrupoGasto { necesidad, entretenimiento, ocio, ahorro_deuda }

class Egreso extends Equatable {
  final String id;
  final Monto monto;
  final FechaFinanciera fecha;
  final String? descripcion;
  final GrupoGasto grupo;
  final String subcategoria;
  final bool recurrente;

  const Egreso({
    required this.id,
    required this.monto,
    required this.fecha,
    this.descripcion,
    required this.grupo,
    required this.subcategoria,
    required this.recurrente,
  });

  Egreso copyWith({
    Monto? monto,
    FechaFinanciera? fecha,
    String? descripcion,
    GrupoGasto? grupo,
    String? subcategoria,
    bool? recurrente,
  }) {
    return Egreso(
      id: id,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
      grupo: grupo ?? this.grupo,
      subcategoria: subcategoria ?? this.subcategoria,
      recurrente: recurrente ?? this.recurrente,
    );
  }

  @override
  List<Object?> get props => [
    id,
    monto,
    fecha,
    grupo,
    subcategoria,
    recurrente,
  ];
}

/// Subcategorías por grupo (para usar en formularios)
class SubcategoriasGasto {
  static const Map<GrupoGasto, List<String>> mapa = {
    GrupoGasto.necesidad: [
      'arriendo',
      'administracion',
      'agua',
      'luz',
      'gas',
      'mantenimiento_hogar',
      'mercado',
      'ropa',
      'plan_celular',
      'internet',
      'transporte',
      'seguros',
      'salud',
      'educacion',
      'cuidado_personal',
      'pago_minimo_deudas',
      'hijos',
      'vehiculo',
    ],
    GrupoGasto.entretenimiento: [
      'streaming',
      'videojuegos',
      'cine',
      'conciertos',
      'suscripciones',
      'deportes',
      'hobbies',
    ],
    GrupoGasto.ocio: [
      'domicilios',
      'apuestas',
      'bares',
      'alcohol',
      'cigarrillo',
      'restaurantes',
      'gimnasio',
      'viajes',
      'libros',
      'mascotas',
      'jardineria',
      'museos',
      'cursos',
      'clubes',
      'compras_online',
      'gadgets',
    ],
    GrupoGasto.ahorro_deuda: ['ahorro_meta', 'pago_extra_deuda'],
  };

  static List<String> obtener(GrupoGasto grupo) => mapa[grupo] ?? [];
}

/// Etiquetas legibles para mostrar en la UI
class EtiquetasGasto {
  static const Map<String, String> _labels = {
    'arriendo': 'Arriendo',
    'administracion': 'Administración',
    'agua': 'Agua',
    'luz': 'Luz',
    'gas': 'Gas',
    'mantenimiento_hogar': 'Mantenimiento hogar',
    'mercado': 'Mercado',
    'ropa': 'Ropa',
    'plan_celular': 'Plan celular',
    'internet': 'Internet',
    'transporte': 'Transporte',
    'seguros': 'Seguros',
    'salud': 'Salud',
    'educacion': 'Educación',
    'cuidado_personal': 'Cuidado personal',
    'pago_minimo_deudas': 'Pago mínimo deudas',
    'hijos': 'Hijos / dependientes',
    'vehiculo': 'Vehículo',
    'streaming': 'Streaming',
    'videojuegos': 'Videojuegos',
    'cine': 'Cine',
    'conciertos': 'Conciertos',
    'suscripciones': 'Suscripciones',
    'deportes': 'Deportes',
    'hobbies': 'Hobbies',
    'domicilios': 'Domicilios',
    'apuestas': 'Apuestas',
    'bares': 'Bares / discotecas',
    'alcohol': 'Alcohol',
    'cigarrillo': 'Cigarrillo',
    'restaurantes': 'Restaurantes',
    'gimnasio': 'Gimnasio',
    'viajes': 'Viajes',
    'libros': 'Libros',
    'mascotas': 'Mascotas',
    'jardineria': 'Jardinería',
    'museos': 'Museos / teatro',
    'cursos': 'Cursos no profesionales',
    'clubes': 'Clubes sociales',
    'compras_online': 'Compras no esenciales online',
    'gadgets': 'Accesorios y tecnología',
    'ahorro_meta': 'Ahorro (meta)',
    'pago_extra_deuda': 'Pago extra a deuda',
  };

  static String label(String key) => _labels[key] ?? key;

  static String labelGrupo(GrupoGasto g) {
    switch (g) {
      case GrupoGasto.necesidad:
        return 'Necesidades';
      case GrupoGasto.entretenimiento:
        return 'Entretenimiento';
      case GrupoGasto.ocio:
        return 'Ocio';
      case GrupoGasto.ahorro_deuda:
        return 'Ahorro / Deuda';
    }
  }
}
