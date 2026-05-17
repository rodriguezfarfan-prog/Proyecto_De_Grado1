import 'package:equatable/equatable.dart';

class Monto extends Equatable {
  final double valor;
  const Monto._(this.valor);

  factory Monto(double valor) {
    if (valor < 0) throw ArgumentError('El monto no puede ser negativo');
    return Monto._(valor);
  }

  Monto operator +(Monto otro) => Monto._(valor + otro.valor);
  Monto operator -(Monto otro) {
    if (valor < otro.valor) throw Exception('Resultado negativo no permitido');
    return Monto._(valor - otro.valor);
  }

  @override
  List<Object?> get props => [valor];
}