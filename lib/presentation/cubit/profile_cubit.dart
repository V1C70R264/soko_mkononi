import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/user/get_user_profile.dart';
import '../../domain/usecases/user/update_profile_details.dart';
import '../../domain/usecases/user/update_user_profile_image.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateUserProfileImage updateUserProfileImage;
  final UpdateProfileDetails updateProfileDetails;

  ProfileCubit(
    this.getUserProfile,
    this.updateUserProfileImage,
    this.updateProfileDetails,
  ) : super(const ProfileState());

  // ─── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchUserProfile() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final user = await getUserProfile();
      emit(state.copyWith(user: user, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  // ─── Profile image upload ───────────────────────────────────────────────────

  Future<bool> uploadProfileImage(File image) async {
    emit(state.copyWith(isUploading: true, error: null));
    try {
      await updateUserProfileImage(image);
      // Always refetch — PATCH responses may omit profile_image or return a
      // stale URL while the backend uploads to Cloudinary asynchronously.
      final user = await getUserProfile();
      emit(
        state.copyWith(
          user: user,
          isUploading: false,
          error: null,
          profileImageVersion: state.profileImageVersion + 1,
        ),
      );
      return true;
    } catch (e) {
      final errorMsg = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
      emit(state.copyWith(error: errorMsg, isUploading: false));
      return false;
    }
  }

  // ─── Profile details update ─────────────────────────────────────────────────

  Future<void> saveProfileDetails({
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    // Prevent duplicate submissions.
    if (state.isSaving) return;

    emit(state.copyWith(isSaving: true, updateSuccess: false, error: null));
    try {
      final user = await updateProfileDetails(
        username: username,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      emit(state.copyWith(user: user, isSaving: false, updateSuccess: true, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isSaving: false));
    }
  }

  /// Called by the UI after it has consumed the [ProfileState.updateSuccess]
  /// flag (e.g. popped the screen / shown the toast) so subsequent rebuilds
  /// don't repeat the side-effect.
  void clearUpdateSuccess() {
    if (state.updateSuccess) {
      emit(state.copyWith(updateSuccess: false));
    }
  }
}
