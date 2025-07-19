import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/network/network_service.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/api_service_locator.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API services
  apiServices.initialize();
  
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
            final authRepository = AuthRepositoryImpl(
              remoteDataSource: apiServices.authService,
            );
            
            return AuthBloc(
              authRepository: authRepository,
              networkService: apiServices.networkService,
            )..add(const AuthStatusChecked());
          },
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(),
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