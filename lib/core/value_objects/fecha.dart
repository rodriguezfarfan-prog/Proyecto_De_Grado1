import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class FechaFinanciera extends Equatable {
  final DateTime fecha;
  const FechaFinanciera._(this.fecha);

  factory FechaFinanciera(DateTime fecha) {
    if (fecha.isAfter(DateTime.now())) {
      throw ArgumentError('La fecha no puede ser futura');
    }
    return FechaFinanciera._(fecha);
  }

  factory FechaFinanciera.now() => FechaFinanciera._(DateTime.now());

  String get formatoCorto => DateFormat('dd/MM/yyyy').format(fecha);

  @override
  List<Object?> get props => [fecha];
}