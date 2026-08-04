import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

// Sentinel used to distinguish "pass null explicitly" from "not passed".
const _kUndefined = Object();

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

  /// Bumped after each successful image upload so avatar widgets can bust
  /// Flutter/CDN caches even when the backend returns the same URL string.
  final int profileImageVersion;

  final String? error;

  const ProfileState({
    this.user,
    this.loading = false,
    this.isUploading = false,
    this.isSaving = false,
    this.updateSuccess = false,
    this.profileImageVersion = 0,
    this.error,
  });

  ProfileState copyWith({
    User? user,
    bool? loading,
    bool? isUploading,
    bool? isSaving,
    bool? updateSuccess,
    int? profileImageVersion,
    // Use Object? so callers can explicitly pass null to clear the error.
    Object? error = _kUndefined,
  }) {
    return ProfileState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      isUploading: isUploading ?? this.isUploading,
      isSaving: isSaving ?? this.isSaving,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      profileImageVersion: profileImageVersion ?? this.profileImageVersion,
      error: identical(error, _kUndefined) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        user,
        loading,
        isUploading,
        isSaving,
        updateSuccess,
        profileImageVersion,
        error,
      ];
}
