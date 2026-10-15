import 'package:dio/dio.dart';
import '/domain/ahorro/usecases/crear_meta_ahorro.dart';
import 'package:get_it/get_it.dart';
import '/domain/ahorro/usecases/crear_meta_ahorro.dart';
import 'package:fin_up_project/domain/diagnostico/usecases/obtener_periodo_anterior.dart';
import 'package:fin_up_project/data/datasources/remote/remote_gamificacion_datasource.dart';
import 'package:fin_up_project/data/datasources/remote/remote_gamificacion_datasource_impl.dart';
import 'package:fin_up_project/data/repositories/gamificacion/gamificacion_repository_impl.dart';
import 'package:fin_up_project/domain/gamificacion/repositories/gamificacion_repository.dart';

//Auth
import '/data/datasources/remote/auth_remote_datasource.dart';
import '/data/datasources/remote/auth_remote_datasource_impl.dart';
import '/data/repositories/usuario/auth_repository_impl.dart';
import '/domain/usuario/repositories/auth_repository.dart';
import '/domain/usuario/usecases/login_usuario.dart';
import '/domain/usuario/usecases/registrar_usuario.dart';

// DataSources remotos
import '/data/datasources/remote/remote_ingreso_datasource.dart';
import '/data/datasources/remote/remote_ingreso_datasource_impl.dart';
import '/data/datasources/remote/remote_egreso_datasource.dart';
import '/data/datasources/remote/remote_egreso_datasource_impl.dart';
import '/data/datasources/remote/remote_meta_ahorro_datasource.dart';
import '/data/datasources/remote/remote_meta_ahorro_datasource_impl.dart';
import '/data/datasources/remote/remote_usuario_datasource.dart';
import '/data/datasources/remote/remote_usuario_datasource_impl.dart';

// Repositorios
import '/data/repositories/diagnostico/ingreso_repository_impl.dart';
import '/data/repositories/diagnostico/egreso_repository_impl.dart';
import '/data/repositories/ahorro/meta_ahorro_repository_impl.dart';
import '/data/repositories/usuario/usuario_repository_impl.dart';

// Abstracciones de dominio
import '/domain/diagnostico/repositories/ingreso_repository.dart';
import '/domain/diagnostico/repositories/egreso_repository.dart';
import '/domain/ahorro/repositories/meta_ahorro_repository.dart';
import '/domain/usuario/repositories/usuario_repository.dart';

// Casos de uso
import '/domain/diagnostico/usecases/realizar_diagnostico.dart';
import '/domain/simulacion/usecases/simular_optimizacion.dart';
import '/domain/ahorro/usecases/planificar_ahorro.dart';
import '/domain/recomendacion/usecases/generar_recomendaciones.dart';
import '/domain/simulacion_compra/usecases/simular_compra.dart';
import '/domain/ahorro/usecases/eliminar_meta_ahorro.dart';
import '/domain/ahorro/usecases/agregar_abono_meta.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  );

  sl.registerLazySingleton<Dio>(() => dio);

  //Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoginUsuario>(
    () => LoginUsuario(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegistrarUsuario>(
    () => RegistrarUsuario(sl<AuthRepository>()),
  );

  // DataSources remotos
  sl.registerLazySingleton<RemoteIngresoDataSource>(
    () => RemoteIngresoDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<RemoteEgresoDataSource>(
    () => RemoteEgresoDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<RemoteMetaAhorroDataSource>(
    () => RemoteMetaAhorroDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<RemoteUsuarioDataSource>(
    () => RemoteUsuarioDataSourceImpl(sl<Dio>()),
  );

  // Repositorios
  sl.registerLazySingleton<IngresoRepository>(
    () => IngresoRepositoryImpl(
      sl<RemoteIngresoDataSource>(),
      sl<AuthRepository>(),
    ),
  );
  sl.registerLazySingleton<EgresoRepository>(
    () => EgresoRepositoryImpl(
      sl<RemoteEgresoDataSource>(),
      sl<AuthRepository>(),
    ),
  );
  sl.registerLazySingleton<MetaAhorroRepository>(
    () => MetaAhorroRepositoryImpl(
      sl<RemoteMetaAhorroDataSource>(),
      sl<AuthRepository>(),
    ),
  );
  sl.registerLazySingleton<UsuarioRepository>(
    () => UsuarioRepositoryImpl(sl<RemoteUsuarioDataSource>()),
  );
  // Gamificación
  sl.registerLazySingleton<RemoteGamificacionDataSource>(
    () => RemoteGamificacionDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<GamificacionRepository>(
    () => GamificacionRepositoryImpl(
      sl<RemoteGamificacionDataSource>(),
      sl<AuthRepository>(),
    ),
  );

  // Casos de uso
  sl.registerLazySingleton<RealizarDiagnostico>(
    () => RealizarDiagnostico(sl<IngresoRepository>(), sl<EgresoRepository>()),
  );
  sl.registerLazySingleton<SimularOptimizacion>(
    () => SimularOptimizacion(sl<EgresoRepository>()),
  );
  sl.registerLazySingleton<PlanificarAhorro>(
    () => PlanificarAhorro(sl<MetaAhorroRepository>(), sl<IngresoRepository>()),
  );
  sl.registerLazySingleton<GenerarRecomendaciones>(
    () => GenerarRecomendaciones(sl<EgresoRepository>()),
  );
  sl.registerLazySingleton<SimularCompra>(
    () => SimularCompra(sl<IngresoRepository>(), sl<EgresoRepository>()),
  );
  sl.registerLazySingleton<CrearMetaAhorro>(
    () => CrearMetaAhorro(sl<MetaAhorroRepository>()),
  );
  sl.registerLazySingleton<EliminarMetaAhorro>(
    () => EliminarMetaAhorro(sl<MetaAhorroRepository>()),
  );
  sl.registerLazySingleton<AgregarAbonoMeta>(
    () => AgregarAbonoMeta(sl<MetaAhorroRepository>()),
  );
  sl.registerLazySingleton<ObtenerPeriodoAnterior>(
    () =>
        ObtenerPeriodoAnterior(sl<IngresoRepository>(), sl<EgresoRepository>()),
  );
}
