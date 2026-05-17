import 'package:equatable/equatable.dart';
import '/domain/diagnostico/entities/egreso.dart';

class ComparativaGastos extends Equatable {
  final Map<CategoriaEgreso, double> actual;
  final Map<CategoriaEgreso, double> ideal;

  const ComparativaGastos({required this.actual, required this.ideal});

  @override
  List<Object?> get props => [actual, ideal];
}