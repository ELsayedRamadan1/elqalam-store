import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call({
    required String userId,
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
  }) {
    return repository.updateProfile(
      userId: userId,
      name: name,
      phone: phone,
      address: address,
      avatarUrl: avatarUrl,
    );
  }
}
