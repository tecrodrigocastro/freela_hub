import 'package:base_clean_arch_bloc/src/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/data/repositories/auth_repository_mock.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/login_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/register_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/infrastructure/auth_interceptor.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/datasources/candidaturas_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/repositories/candidaturas_repository_impl.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/repositories/candidaturas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/get_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/get_candidaturas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/retirar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidatura_detail_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidaturas_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/enviar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidatura_form_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/services/candidatura_sent_notifier.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/data/datasources/perfil_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/data/repositories/perfil_repository_impl.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/repositories/perfil_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/get_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/logout_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/update_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/bloc/perfil_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/data/datasources/vagas_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/data/repositories/vagas_repository_impl.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/repositories/vagas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_categorias_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vaga_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vagas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vaga_detail_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vagas_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/cache/shared_preferences/shared_preferences_impl.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/dio/rest_client_dio_impl.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/session_expired_interceptor.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/logger/client_interceptor_logger_impl.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

final injector = GetIt.instance;

void setupDependencyInjector(
    {bool loggerApi = false, bool useMocks = true, Logger? logger}) {
  injector.registerLazySingleton<Logger>(() => logger ?? Logger());

  injector.registerFactory<RestClientDioImpl>(() {
    final instance = RestClientDioImpl(
      dio: DioFactory.dio(),
    );

    instance.addInterceptors(AuthInterceptor(
      sessionService: injector<SessionService>(),
    ));

    instance.addInterceptors(SessionExpiredInterceptor(
      sessionService: injector<SessionService>(),
    ));

    if (loggerApi) {
      instance.addInterceptors(
          ClientInterceptorLoggerImpl(logger: injector<Logger>()));
    }

    return instance;
  });

  injector.registerLazySingleton<SessionService>(() {
    return SessionService(
      sharedPreferencesImpl: SharedPreferencesImpl(),
    );
  });

  injector.registerLazySingleton<AuthRemoteDatasource>(() {
    return AuthRemoteDatasource(
      restClient: injector<RestClientDioImpl>(),
    );
  });

  if (useMocks) {
    injector.registerLazySingleton<IAuthRepository>(() => AuthRepositoryMock());
  } else {
    injector.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(
        authRemoteDatasource: injector<AuthRemoteDatasource>()));
  }

  // Factory: cada tela (Splash, Login, Cadastro) tem o seu próprio bloc, sem estado herdado.
  injector.registerFactory(() => AuthBloc(
        loginUsecase: LoginUsecase(
          authRepository: injector<IAuthRepository>(),
          sessionService: injector<SessionService>(),
        ),
        registerUsecase: RegisterUsecase(
          authRepository: injector<IAuthRepository>(),
          sessionService: injector<SessionService>(),
        ),
        checkSessionUsecase:
            CheckSessionUsecase(sessionService: injector<SessionService>()),
      ));

  injector.registerLazySingleton<VagasRemoteDatasource>(() => VagasRemoteDatasource(restClient: injector<RestClientDioImpl>()));
  injector.registerLazySingleton<IVagasRepository>(() => VagasRepositoryImpl(datasource: injector<VagasRemoteDatasource>()));
  injector.registerFactory(() => VagaDetailBloc(getVagaUsecase: GetVagaUsecase(vagasRepository: injector<IVagasRepository>())));
  injector.registerFactory(() => VagasBloc(
        sentNotifier: injector<CandidaturaSentNotifier>(),
        getVagasUsecase: GetVagasUsecase(vagasRepository: injector<IVagasRepository>()),
        getCategoriasUsecase: GetCategoriasUsecase(vagasRepository: injector<IVagasRepository>()),
      ));

  injector.registerLazySingleton<CandidaturaSentNotifier>(() => CandidaturaSentNotifier());
  injector.registerLazySingleton<CandidaturasRemoteDatasource>(() => CandidaturasRemoteDatasource(restClient: injector<RestClientDioImpl>()));
  injector.registerLazySingleton<ICandidaturasRepository>(() => CandidaturasRepositoryImpl(datasource: injector<CandidaturasRemoteDatasource>()));
  injector.registerFactory(() => CandidaturaFormBloc(
        enviarCandidaturaUsecase: EnviarCandidaturaUsecase(
          candidaturasRepository: injector<ICandidaturasRepository>(),
          sentNotifier: injector<CandidaturaSentNotifier>(),
        ),
      ));
  injector.registerFactory(() => CandidaturasBloc(
        getCandidaturasUsecase: GetCandidaturasUsecase(candidaturasRepository: injector<ICandidaturasRepository>()),
        retirarCandidaturaUsecase: RetirarCandidaturaUsecase(candidaturasRepository: injector<ICandidaturasRepository>()),
        sentNotifier: injector<CandidaturaSentNotifier>(),
      ));
  injector.registerFactory(() => CandidaturaDetailBloc(getCandidaturaUsecase: GetCandidaturaUsecase(candidaturasRepository: injector<ICandidaturasRepository>())));

  injector.registerLazySingleton<PerfilRemoteDatasource>(() => PerfilRemoteDatasource(restClient: injector<RestClientDioImpl>()));
  injector.registerLazySingleton<IPerfilRepository>(() => PerfilRepositoryImpl(datasource: injector<PerfilRemoteDatasource>()));
  injector.registerFactory(() => PerfilBloc(
        getPerfilUsecase: GetPerfilUsecase(perfilRepository: injector<IPerfilRepository>()),
        updatePerfilUsecase: UpdatePerfilUsecase(perfilRepository: injector<IPerfilRepository>()),
        logoutUsecase: LogoutUsecase(
          perfilRepository: injector<IPerfilRepository>(),
          sessionService: injector<SessionService>(),
        ),
      ));
}
