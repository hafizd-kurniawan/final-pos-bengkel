import '../../core/network/network_service.dart';
import '../models/user.dart';

class UserApiService {
  final NetworkService _networkService;

  UserApiService(this._networkService);

  Future<List<User>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? search,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (role != null) queryParams['role'] = role;
    if (search != null) queryParams['search'] = search;
    if (isActive != null) queryParams['is_active'] = isActive.toString();

    final response = await _networkService.get(
      '/users',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final usersList = response.data['data']['users'] as List;
      return usersList.map((user) => User.fromJson(user)).toList();
    }

    throw Exception('Failed to fetch users');
  }

  Future<User> getUser(int id) async {
    final response = await _networkService.get('/users/$id');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return User.fromJson(response.data['data']);
    }

    throw Exception('Failed to fetch user');
  }

  Future<User> createUser({
    required String email,
    required String password,
    required String name,
    String? phone,
    required UserRole role,
  }) async {
    final data = {
      'email': email,
      'password': password,
      'name': name,
      'role': role.value,
      if (phone != null) 'phone': phone,
    };

    final response = await _networkService.post('/users', data: data);

    if (response.statusCode == 201 && response.data['status'] == 'success') {
      return User.fromJson(response.data['data']);
    }

    throw Exception('Failed to create user');
  }

  Future<User> updateUser({
    required int id,
    String? name,
    String? phone,
    UserRole? role,
    bool? isActive,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{};
    
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (role != null) data['role'] = role.value;
    if (isActive != null) data['is_active'] = isActive;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;

    final response = await _networkService.put('/users/$id', data: data);

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return User.fromJson(response.data['data']);
    }

    throw Exception('Failed to update user');
  }

  Future<void> deleteUser(int id) async {
    final response = await _networkService.delete('/users/$id');

    if (response.statusCode != 200 || response.data['status'] != 'success') {
      throw Exception('Failed to delete user');
    }
  }

  Future<void> changePassword({
    required int id,
    required String currentPassword,
    required String newPassword,
  }) async {
    final data = {
      'current_password': currentPassword,
      'new_password': newPassword,
    };

    final response = await _networkService.put('/users/$id/password', data: data);

    if (response.statusCode != 200 || response.data['status'] != 'success') {
      throw Exception('Failed to change password');
    }
  }

  Future<Map<String, dynamic>> getUserAnalytics() async {
    final response = await _networkService.get('/users/analytics');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return response.data['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to fetch user analytics');
  }

  Future<User> getProfile() async {
    final response = await _networkService.get('/profile');

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return User.fromJson(response.data['data']);
    }

    throw Exception('Failed to fetch profile');
  }

  Future<User> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{};
    
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;

    final response = await _networkService.put('/profile', data: data);

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return User.fromJson(response.data['data']);
    }

    throw Exception('Failed to update profile');
  }

  Future<void> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final data = {
      'current_password': currentPassword,
      'new_password': newPassword,
    };

    final response = await _networkService.put('/profile/password', data: data);

    if (response.statusCode != 200 || response.data['status'] != 'success') {
      throw Exception('Failed to change password');
    }
  }

  Future<List<User>> getSalesPersons() async {
    return getUsers(role: 'sales');
  }

  Future<List<User>> getCustomers() async {
    return getUsers(role: 'customer');
  }

  Future<List<User>> getCashiers() async {
    return getUsers(role: 'cashier');
  }

  Future<List<User>> getAdmins() async {
    return getUsers(role: 'admin');
  }
}