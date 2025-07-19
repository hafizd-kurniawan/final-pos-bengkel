import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/auth.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../core/network/network_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final NetworkService _networkService;

  AuthBloc({
    required AuthRepository authRepository,
    required NetworkService networkService,
  })  : _authRepository = authRepository,
        _networkService = networkService,
        super(const AuthInitial()) {
    
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthTokenRefreshed>(_onTokenRefreshed);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );
      
      final response = await _authRepository.login(request);
      
      // Set token in network service
      _networkService.setAuthToken(response.token);
      
      emit(AuthAuthenticated(
        user: response.user,
        token: response.token,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final request = RegisterRequest(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        role: event.role,
      );
      
      final response = await _authRepository.register(request);
      
      // Set token in network service
      _networkService.setAuthToken(response.token);
      
      emit(AuthAuthenticated(
        user: response.user,
        token: response.token,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
      
      // Clear token from network service
      _networkService.clearAuthToken();
      
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await _authRepository.getStoredToken();
      
      if (token != null && token.isNotEmpty) {
        // Set token in network service
        _networkService.setAuthToken(token);
        
        // TODO: Validate token and get user info
        // For now, just emit unauthenticated
        emit(const AuthUnauthenticated());
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onTokenRefreshed(
    AuthTokenRefreshed event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.saveToken(event.token);
      _networkService.setAuthToken(event.token);
      
      // TODO: Get updated user info
      // For now, keep current state if authenticated
      if (state is AuthAuthenticated) {
        final currentState = state as AuthAuthenticated;
        emit(AuthAuthenticated(
          user: currentState.user,
          token: event.token,
        ));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}