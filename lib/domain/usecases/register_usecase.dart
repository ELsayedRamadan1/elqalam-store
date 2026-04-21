import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(String email, String password, String name) {
    return repository.register(email, password, name);
  }
}
