import 'package:equatable/equatable.dart';

class ComparativaGastos extends Equatable {
  final Map<String, double> actual;
  final Map<String, double> ideal;

  const ComparativaGastos({required this.actual, required this.ideal});

  @override
  List<Object?> get props => [actual, ideal];
}
