import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_up_project/di/injection_container.dart';
import 'package:fin_up_project/domain/gamificacion/entities/logro.dart';
import 'package:fin_up_project/domain/gamificacion/entities/perfil_gamificacion.dart';
import 'package:fin_up_project/domain/gamificacion/repositories/gamificacion_repository.dart';
import 'package:fin_up_project/presentation/shared/base_view_model.dart';

final gamificacionViewModelProvider =
    StateNotifierProvider<GamificacionViewModel, BaseState<PerfilGamificacion>>(
      (ref) => GamificacionViewModel(sl<GamificacionRepository>()),
    );

class GamificacionViewModel extends BaseViewModel<PerfilGamificacion> {
  final GamificacionRepository _repo;
  GamificacionViewModel(this._repo);

  Future<void> cargarPerfil() async {
    emitLoading();
    final result = await _repo.obtenerPerfil();
    result.fold(
      (failure) => emitError(failure.message),
      (perfil) => emitData(perfil),
    );
  }

  Future<void> sumarPuntos(int puntos) async {
    await _repo.sumarPuntos(puntos);
  }

  Future<Logro?> desbloquearLogro(Logro logro) async {
    print('🎮 Intentando desbloquear logro: ${logro.id}');
    final result = await _repo.desbloquearLogro(logro);
    return result.fold(
      (failure) {
        print('❌ Error desbloqueando logro: ${failure.message}');
        return null;
      },
      (esNuevo) {
        print('✅ Logro ${logro.id}: nuevo=$esNuevo');
        return esNuevo ? logro : null;
      },
    );
  }

  Future<int> registrarAccion(String tipoAccion) async {
    final result = await _repo.registrarAccion(tipoAccion);
    return result.fold(
      (failure) {
        print('❌ Error registrando acción: ${failure.message}');
        return 0;
      },
      (puntos) {
        print('➕ Acción $tipoAccion → +$puntos pts');
        return puntos;
      },
    );
  }

  /// Registra la visita del día. Retorna un mapa con puntosOtorgados y rachaActual.
  Future<Map<String, dynamic>> registrarRacha() async {
    final result = await _repo.registrarRacha();
    return result.fold(
      (failure) {
        print('❌ Error registrando racha: ${failure.message}');
        return {'puntosOtorgados': 0, 'rachaActual': 0};
      },
      (data) {
        final puntos = data['puntosOtorgados'] ?? 0;
        final racha = data['rachaActual'] ?? 0;
        print('🔥 Racha: $racha días → +$puntos pts');
        cargarPerfil();
        return {'puntosOtorgados': puntos, 'rachaActual': racha};
      },
    );
  }
}
