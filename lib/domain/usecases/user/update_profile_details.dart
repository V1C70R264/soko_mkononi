import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class UpdateProfileDetails {
  final UserRepository repository;

  UpdateProfileDetails(this.repository);

  Future<User> call({
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) =>
      repository.updateProfileDetails(
        username: username,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
}
