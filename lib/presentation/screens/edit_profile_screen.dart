import 'dart:convert';
import 'dart:io';

import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/data/models/user_model.dart';
import 'package:e_commerce/domain/entities/user.dart';
import 'package:e_commerce/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce/presentation/cubit/profile_state.dart';
import 'package:e_commerce/presentation/widgets/auth_custom_widgets.dart';
import 'package:e_commerce/presentation/widgets/authentication_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EditProfileScreen
// ─────────────────────────────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // ── State tracking ────────────────────────────────────────────────────────
  /// Baseline values captured once the user profile is loaded.
  String _originalUsername = '';
  String _originalFullName = '';
  String _originalPhone = '';

  /// Local file chosen for upload (cleared after upload completes).
  File? _localImage;

  /// Whether we've already seeded the form controllers (done once).
  bool _formSeeded = false;

  /// Tracks the last error we showed to prevent duplicate snackbars.
  String? _lastHandledError;

  /// Unique key incremented on every successful image upload to bust
  /// Flutter's NetworkImage cache so the avatar always shows fresh.
  int _imageKey = 0;

  /// Tracks whether an upload was in-progress on the previous state, so we
  /// can detect the upload-done transition in [_handleStateChanges].
  bool _wasUploading = false;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Seeds form controllers from the loaded [user] — called once.
  void _seedFormFromUser(User user) {
    _originalUsername = user.username ?? '';
    _originalFullName = user.fullName ?? '';
    _originalPhone = user.phoneNumber ?? '';

    _usernameController.text = _originalUsername;
    _fullNameController.text = _originalFullName;
    _phoneController.text = _originalPhone;

    _formSeeded = true;
  }

  bool get _hasChanges =>
      _usernameController.text.trim() != _originalUsername ||
      _fullNameController.text.trim() != _originalFullName ||
      _phoneController.text.trim() != _originalPhone;

  ImageProvider? _resolveImageProvider(String? networkUrl, File? localFile) {
    if (localFile != null) return FileImage(localFile);
    if (networkUrl != null && networkUrl.trim().isNotEmpty) {
      final resolved = UserModel.resolveImageUrl(networkUrl);
      if (resolved != null) {
        if (resolved.startsWith('data:image/')) {
          try {
            final bytes = base64Decode(resolved.split(',').last);
            return MemoryImage(bytes);
          } catch (_) {}
        } else if (resolved.startsWith('http://') ||
            resolved.startsWith('https://')) {
          return NetworkImage(resolved);
        }
      }
    }
    return null;
  }

  String _initialsFor(User user) {
    final full = user.fullName?.trim() ?? '';
    if (full.isNotEmpty) {
      final parts = full.split(RegExp(r'\s+'));
      final first = parts.first[0];
      final last = parts.length > 1 ? parts.last[0] : '';
      return (first + last).toUpperCase();
    }
    final uname = user.username?.trim() ?? '';
    if (uname.isNotEmpty) {
      return uname.substring(0, uname.length >= 2 ? 2 : 1).toUpperCase();
    }
    return user.email.substring(0, 2).toUpperCase();
  }

  // ── Back-navigation guard ─────────────────────────────────────────────────

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Discard Changes?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E262C),
          ),
        ),
        content: const Text(
          'You have unsaved changes. Are you sure you want to go back?',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Discard',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  // ── Image picking & upload ────────────────────────────────────────────────

  void _showImageOptions(bool hasImage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ImagePickerSheet(
        onCamera: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGallery: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onRemove: hasImage
            ? () {
                Navigator.pop(context);
                _removeImage();
              }
            : null,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    // Capture the old URL so we can evict Flutter's NetworkImage cache.
    final oldImageUrl = context.read<ProfileCubit>().state.user?.profileImage;

    // Show local preview immediately.
    setState(() => _localImage = file);

    // Reset the last handled error so the listener can react to a fresh error.
    _lastHandledError = null;

    await context.read<ProfileCubit>().uploadProfileImage(file);

    // After upload, evict old & new cached network images and bump the key
    // so Flutter ignores any cached NetworkImage for the avatar widget.
    if (mounted) {
      _evictNetworkImage(oldImageUrl);
      final newImageUrl =
          context.read<ProfileCubit>().state.user?.profileImage;
      _evictNetworkImage(newImageUrl);

      // Increment key to force CircleAvatar to re-render with fresh image.
      setState(() {
        _localImage = null;
        _imageKey++;
      });
    }
  }

  /// Evicts [url] from Flutter's image cache if it is a network URL.
  void _evictNetworkImage(String? url) {
    if (url == null || url.isEmpty) return;
    final resolved = UserModel.resolveImageUrl(url);
    if (resolved != null &&
        (resolved.startsWith('http://') || resolved.startsWith('https://'))) {
      NetworkImage(resolved).evict();
    }
  }

  Future<void> _removeImage() async {
    // Optimistically clear local preview; actual removal depends on backend support.
    setState(() => _localImage = null);
    _showInfo('Photo removed');
  }

  // ── Form save ─────────────────────────────────────────────────────────────

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();

    await context.read<ProfileCubit>().saveProfileDetails(
          username: _usernameController.text.trim(),
          firstName: _fullNameController.text.trim().split(' ').first,
          lastName: _fullNameController.text.trim().split(' ').length > 1
              ? _fullNameController.text.trim().split(' ').skip(1).join(' ')
              : null,
          phoneNumber: _phoneController.text.trim(),
        );
  }

  // ── Snackbars ─────────────────────────────────────────────────────────────

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(msg),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, maxLines: 2)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showInfo(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            // ── Initial load ──────────────────────────────────────────────
            if (state.loading && state.user == null) {
              return const _LoadingView();
            }

            // ── Fatal error (no user yet) ─────────────────────────────────
            if (state.error != null && state.user == null) {
              return _ErrorView(
                message: state.error!,
                onRetry: () =>
                    context.read<ProfileCubit>().fetchUserProfile(),
              );
            }

            // ── Seed form once user is available ─────────────────────────
            final user = state.user;
            if (!_formSeeded && user != null) {
              // Use addPostFrameCallback to avoid setState during build.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _seedFormFromUser(user));
                }
              });
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Header (matches Login / Signup pattern) ──
                              AuthHeader(
                                title: 'Edit Profile',
                                subtitle:
                                    'Update your personal information below',
                                showBackButton: true,
                              ),
                              const SizedBox(height: 32),

                              // ── Avatar ────────────────────────────────────
                              _AvatarSection(
                                key: ValueKey(_imageKey),
                                user: user,
                                localImage: _localImage,
                                isUploading: state.isUploading,
                                resolveImage: _resolveImageProvider,
                                initialsFor: _initialsFor,
                                onTap: () => _showImageOptions(
                                  _localImage != null ||
                                      (user?.profileImage != null &&
                                          user!.profileImage!.isNotEmpty),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // ── Form card ─────────────────────────────────
                              _FormCard(
                                usernameController: _usernameController,
                                fullNameController: _fullNameController,
                                phoneController: _phoneController,
                                email: user?.email ?? '',
                                isSaving: state.isSaving,
                              ),
                              const SizedBox(height: 28),

                              // ── Save button ───────────────────────────────
                              _SaveButton(
                                isSaving: state.isSaving,
                                hasChanges: _hasChanges,
                                onPressed: _saveChanges,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── BlocConsumer listener ─────────────────────────────────────────────────

  void _handleStateChanges(BuildContext context, ProfileState state) {
    // Success → show SnackBar, pop screen
    if (state.updateSuccess) {
      context.read<ProfileCubit>().clearUpdateSuccess();
      _showSuccess('Profile updated successfully!');
      final nav = Navigator.of(context);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) nav.pop();
      });
    }

    // Detect upload-done transition: was uploading → now done with no error.
    if (_wasUploading && !state.isUploading && state.error == null) {
      _showSuccess('Profile photo updated!');
    }
    _wasUploading = state.isUploading;

    // Error with user present → show SnackBar (non-fatal).
    // Guard: only show once per unique error message, and only when
    // neither an upload nor a save is actively in progress.
    final err = state.error;
    if (err != null &&
        err != _lastHandledError &&
        !state.isUploading &&
        !state.isSaving &&
        state.user != null) {
      _lastHandledError = err;
      _showError(err);
    }
    // If error cleared, reset our tracker.
    if (err == null) _lastHandledError = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingView
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorView
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                      color: const Color(0xFFE5E8EB), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF1E262C),
                  size: 22,
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Failed to load profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E262C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryPillButton(
                    text: 'Try Again',
                    onPressed: onRetry,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AvatarSection
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final User? user;
  final File? localImage;
  final bool isUploading;
  final ImageProvider? Function(String?, File?) resolveImage;
  final String Function(User) initialsFor;
  final VoidCallback onTap;

  const _AvatarSection({
    super.key,
    required this.user,
    required this.localImage,
    required this.isUploading,
    required this.resolveImage,
    required this.initialsFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = resolveImage(user?.profileImage, localImage);
    final showInitials = imageProvider == null;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: isUploading ? null : onTap,
            child: Stack(
              children: [
                // ── Gradient ring ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, Color(0xFF2D3748)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: imageProvider,
                      child: showInitials
                          ? Text(
                              user != null ? initialsFor(user!) : '?',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),

                // ── Upload progress overlay ────────────────────────────
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x88000000),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Camera icon ────────────────────────────────────────
                if (!isUploading)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isUploading ? 'Uploading…' : 'Tap to change photo',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FormCard  (white rounded card containing all form fields)
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final String email;
  final bool isSaving;

  const _FormCard({
    required this.usernameController,
    required this.fullNameController,
    required this.phoneController,
    required this.email,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(text: 'Account Information'),
          const SizedBox(height: 16),

          // ── Username ──────────────────────────────────────────────────
          AuthenticationField(
            controller: usernameController,
            label: 'Username',
            hint: 'e.g. john_doe',
            prefixIcon: Icons.alternate_email_rounded,
            enabled: !isSaving,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
              LengthLimitingTextInputFormatter(30),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Username is required';
              }
              if (v.trim().length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 4),
          const _FieldHint(text: 'No spaces allowed. Min 3 characters.'),
          const SizedBox(height: 18),

          // ── Full Name ─────────────────────────────────────────────────
          AuthenticationField(
            controller: fullNameController,
            label: 'Full Name',
            hint: 'e.g. John Doe',
            prefixIcon: Icons.person_outline_rounded,
            enabled: !isSaving,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // ── Phone Number ──────────────────────────────────────────────
          AuthenticationField(
            controller: phoneController,
            label: 'Phone Number',
            hint: 'e.g. +254 700 000 000',
            prefixIcon: Icons.phone_outlined,
            enabled: !isSaving,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
              LengthLimitingTextInputFormatter(20),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Phone number is required';
              }
              final digits = v.replaceAll(RegExp(r'\D'), '');
              if (digits.length < 9) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // ── Divider ───────────────────────────────────────────────────
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          const SizedBox(height: 20),

          const _SectionLabel(text: 'Email Address'),
          const SizedBox(height: 16),

          // ── Email (read-only) ─────────────────────────────────────────
          _ReadOnlyEmailField(email: email),
          const SizedBox(height: 10),
          _EmailVerificationNote(),
        ],
      ),
    );
  }
}

// ── Small reusable label inside the form card ─────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _FieldHint extends StatelessWidget {
  final String text;
  const _FieldHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

// ── Read-only email input ─────────────────────────────────────────────────────

class _ReadOnlyEmailField extends StatelessWidget {
  final String email;
  const _ReadOnlyEmailField({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECEF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const Icon(
            Icons.email_outlined,
            color: Color(0xFF78828A),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              email.isNotEmpty ? email : 'No email set',
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFFCBD5E1),
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ── Email verification note ───────────────────────────────────────────────────

class _EmailVerificationNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryGreen,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'To change your email address, contact our support team. '
              'Email changes require identity verification.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF166534),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SaveButton
// ─────────────────────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final bool hasChanges;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isSaving,
    required this.hasChanges,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hasChanges ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 250),
      child: PrimaryPillButton(
        text: 'Save Changes',
        isLoading: isSaving,
        onPressed: hasChanges && !isSaving ? onPressed : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ImagePickerSheet  — bottom sheet for picking profile image source
// ─────────────────────────────────────────────────────────────────────────────

class _ImagePickerSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onRemove;

  const _ImagePickerSheet({
    required this.onCamera,
    required this.onGallery,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E262C),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 4),

            // ── Take Photo ─────────────────────────────────────────────
            _SheetTile(
              icon: Icons.camera_alt_rounded,
              iconColor: AppTheme.primaryGreen,
              iconBg: const Color(0xFFE8F8EF),
              label: 'Take Photo',
              onTap: onCamera,
            ),

            // ── Choose from Gallery ────────────────────────────────────
            _SheetTile(
              icon: Icons.photo_library_rounded,
              iconColor: const Color(0xFF3B82F6),
              iconBg: const Color(0xFFEFF6FF),
              label: 'Choose from Gallery',
              onTap: onGallery,
            ),

            // ── Remove Photo (only if image exists) ────────────────────
            if (onRemove != null)
              _SheetTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFDC2626),
                iconBg: const Color(0xFFFEF2F2),
                label: 'Remove Photo',
                onTap: onRemove!,
              ),

            const SizedBox(height: 8),

            // ── Cancel ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  backgroundColor: const Color(0xFFF8FAFC),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Individual tile inside _ImagePickerSheet ──────────────────────────────────

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E262C),
        ),
      ),
    );
  }
}
