import '../models/auth.dart';
import '../datasources/auth_remote_datasource.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<String?> getStoredToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  // TODO: Add local data source for token storage

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _remoteDataSource.login(request);
      // TODO: Save token to local storage
      await saveToken(response.token);
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _remoteDataSource.register(request);
      // TODO: Save token to local storage
      await saveToken(response.token);
      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await clearToken();
      // TODO: Clear user data from local storage
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<String?> getStoredToken() async {
    // TODO: Implement secure storage
    // For now, return null
    return null;
  }

  @override
  Future<void> saveToken(String token) async {
    // TODO: Implement secure storage
    // For now, do nothing
  }

  @override
  Future<void> clearToken() async {
    // TODO: Implement secure storage clearing
    // For now, do nothing
  }
}