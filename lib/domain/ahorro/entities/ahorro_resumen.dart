import 'package:equatable/equatable.dart';
import 'meta_ahorro.dart';

class AhorroResumen extends Equatable {
  final List<MetaAhorro> metas;
  final double totalAhorrado;

  const AhorroResumen({required this.metas, required this.totalAhorrado});

  @override
  List<Object?> get props => [metas, totalAhorrado];
}
