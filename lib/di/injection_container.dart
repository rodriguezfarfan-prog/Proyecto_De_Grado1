import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

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

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Dio
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000/api', // Ajusta según tu entorno
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  sl.registerLazySingleton<Dio>(() => dio);

  // DataSources remotos
  sl.registerLazySingleton<RemoteIngresoDataSource>(() => RemoteIngresoDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<RemoteEgresoDataSource>(() => RemoteEgresoDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<RemoteMetaAhorroDataSource>(() => RemoteMetaAhorroDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<RemoteUsuarioDataSource>(() => RemoteUsuarioDataSourceImpl(sl<Dio>()));

  // Repositorios
  sl.registerLazySingleton<IngresoRepository>(() => IngresoRepositoryImpl(sl<RemoteIngresoDataSource>()));
  sl.registerLazySingleton<EgresoRepository>(() => EgresoRepositoryImpl(sl<RemoteEgresoDataSource>()));
  sl.registerLazySingleton<MetaAhorroRepository>(() => MetaAhorroRepositoryImpl(sl<RemoteMetaAhorroDataSource>()));
  sl.registerLazySingleton<UsuarioRepository>(() => UsuarioRepositoryImpl(sl<RemoteUsuarioDataSource>()));

  // Casos de uso
  sl.registerLazySingleton<RealizarDiagnostico>(() => RealizarDiagnostico(sl<IngresoRepository>(), sl<EgresoRepository>()));
  sl.registerLazySingleton<SimularOptimizacion>(() => SimularOptimizacion(sl<EgresoRepository>()));
  sl.registerLazySingleton<PlanificarAhorro>(() => PlanificarAhorro(sl<MetaAhorroRepository>(), sl<IngresoRepository>()));
  sl.registerLazySingleton<GenerarRecomendaciones>(() => GenerarRecomendaciones(sl<EgresoRepository>()));
  sl.registerLazySingleton<SimularCompra>(
  () => SimularCompra(sl<IngresoRepository>(), sl<EgresoRepository>()),
);
}