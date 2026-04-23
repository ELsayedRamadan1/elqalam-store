import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
  });
}
