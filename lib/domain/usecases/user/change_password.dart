// lib/domain/usecases/user/change_password.dart
import '../../repositories/user_repository.dart';

class ChangePassword {
  final UserRepository repository;
  ChangePassword(this.repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}