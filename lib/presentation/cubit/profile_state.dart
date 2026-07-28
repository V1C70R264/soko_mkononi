import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

class ProfileState extends Equatable {
  final User? user;

  /// True while the initial profile fetch is in progress.
  final bool loading;

  /// True while a profile-image upload is in progress.
  final bool isUploading;

  /// True while profile details (name/phone) are being saved.
  final bool isSaving;

  /// Momentarily set to true after a successful profile-details update.
  /// The UI should consume this and reset it (e.g. pop the edit screen).
  final bool updateSuccess;

  final String? error;

  const ProfileState({
    this.user,
    this.loading = false,
    this.isUploading = false,
    this.isSaving = false,
    this.updateSuccess = false,
    this.error,
  });

  ProfileState copyWith({
    User? user,
    bool? loading,
    bool? isUploading,
    bool? isSaving,
    bool? updateSuccess,
    String? error,
  }) {
    return ProfileState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      isUploading: isUploading ?? this.isUploading,
      isSaving: isSaving ?? this.isSaving,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [user, loading, isUploading, isSaving, updateSuccess, error];
}
