import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_datasource.dart' as auth_ds;

class AuthRepositoryImpl implements AuthRepository {
  final auth_ds.AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<User> login(String email, String password) async {
    return await datasource.login(email, password);
  }

  @override
  Future<User> register(String email, String password, String name) async {
    return await datasource.register(email, password, name);
  }

  @override
  Future<void> logout() {
    return datasource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await datasource.getCurrentUser();
  }
}
