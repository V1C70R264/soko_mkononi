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
      emit(state.copyWith(user: user, loading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  // ─── Profile image upload ───────────────────────────────────────────────────

  Future<void> uploadProfileImage(File image) async {
    emit(state.copyWith(isUploading: true, error: null));
    try {
      final user = await updateUserProfileImage(image);
      emit(state.copyWith(user: user, isUploading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isUploading: false));
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
      emit(state.copyWith(user: user, isSaving: false, updateSuccess: true));
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
