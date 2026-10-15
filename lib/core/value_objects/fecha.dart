import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class FechaFinanciera extends Equatable {
  final DateTime fecha;
  const FechaFinanciera._(this.fecha);

  factory FechaFinanciera(DateTime fecha) {
    // Si la fecha viene en UTC, la convertimos a hora local
    final fechaLocal = fecha.isUtc ? fecha.toLocal() : fecha;
    final now = DateTime.now();

    // Comparamos solo el día (año, mes, día), ignorando la hora
    final fechaDia = DateTime(
      fechaLocal.year,
      fechaLocal.month,
      fechaLocal.day,
    );
    final hoyDia = DateTime(now.year, now.month, now.day);

    if (fechaDia.isAfter(hoyDia)) {
      throw ArgumentError('La fecha no puede ser futura');
    }
    return FechaFinanciera._(fechaLocal);
  }

  factory FechaFinanciera.now() => FechaFinanciera._(DateTime.now());

  String get formatoCorto => DateFormat('dd/MM/yyyy').format(fecha);

  @override
  List<Object?> get props => [fecha];
}
