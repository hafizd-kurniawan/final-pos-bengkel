import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/network/network_service.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize network service
  NetworkService().initialize();
  
  runApp(const VehicleSalesApp());
}

class VehicleSalesApp extends StatelessWidget {
  const VehicleSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final networkService = NetworkService();
            final authRemoteDataSource = AuthRemoteDataSourceImpl(
              networkService: networkService,
            );
            final authRepository = AuthRepositoryImpl(
              remoteDataSource: authRemoteDataSource,
            );
            
            return AuthBloc(
              authRepository: authRepository,
              networkService: networkService,
            )..add(const AuthStatusChecked());
          },
        ),
      ],
      child: MaterialApp(
        title: 'Vehicle Sales',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/splash': (context) => const SplashPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}