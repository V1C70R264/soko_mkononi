import '../entities/user.dart';
import 'dart:io';

abstract class UserRepository {
  Future<User> getUserProfile();
  Future<User> updateProfileImage(File image);
  Future<User> updateProfileDetails({
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });
  // user_repository.dart — add to the abstract class:
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
