import 'dart:convert';
import 'dart:io';
import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/data/models/user_model.dart';
import 'package:e_commerce/domain/entities/user.dart';
import 'package:e_commerce/main.dart';
import 'package:e_commerce/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce/presentation/cubit/profile_state.dart';
import 'package:e_commerce/presentation/screens/cart_screen.dart';
import 'package:e_commerce/presentation/screens/favorites_screen.dart';
import 'package:e_commerce/presentation/screens/login_screen.dart';
import 'package:e_commerce/presentation/screens/edit_profile_screen.dart';
import 'package:e_commerce/presentation/screens/orders_screen.dart';
import 'package:e_commerce/presentation/widgets/auth_custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/presentation/screens/addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool _notificationsEnabled = true;

  /// Unique key incremented on successful upload to bust Flutter's NetworkImage
  /// cache so the avatar always re-renders with the fresh server image.
  int _imageKey = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1E262C),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1E262C),
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.loading && state.user == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            );
          }

          if (state.error != null && state.user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load profile',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E262C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileCubit>().fetchUserProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = state.user;
          final displayName = _getDisplayName(user);
          final emailText = user?.email ?? 'No email';
          final phoneText = (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty)
              ? user.phoneNumber!
              : 'Add phone number';

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _profileImage = null;
              });
              await context.read<ProfileCubit>().fetchUserProfile();
            },
            color: AppTheme.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flat, minimal header — avatar + name + email only.
                  _buildProfileHeader(
                    user: user,
                    displayName: displayName,
                    emailText: emailText,
                  ),
                  const SizedBox(height: 28),

                  _buildFlatSectionList([
                    _FlatTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const OrdersScreen()),
                        );
                      },
                    ),
                    _FlatTile(
                      icon: Icons.shopping_cart_outlined,
                      title: 'My Cart',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      },
                    ),
                    _FlatTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Wishlist & Favorites',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                        );
                      },
                    ),
                    _FlatTile(
                      icon: Icons.location_on_outlined,
                      title: 'Shipping Addresses',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressesScreen()),
                      ),
                    ),
                    _FlatTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Methods',
                      onTap: () => _showFeatureSnackBar('Payment methods feature'),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildFlatSectionList([
                    _FlatTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Details',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                    _FlatTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Security & Password',
                      onTap: () => _showFeatureSnackBar('Security settings'),
                    ),
                    _FlatTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      trailingWidget: Switch.adaptive(
                        value: _notificationsEnabled,
                        activeThumbColor: AppTheme.primaryGreen,
                        activeTrackColor: AppTheme.primaryGreen.withValues(alpha: 0.5),
                        onChanged: (val) {
                          setState(() {
                            _notificationsEnabled = val;
                          });
                        },
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildFlatSectionList([
                    _FlatTile(
                      icon: Icons.language_rounded,
                      title: 'App Language',
                      trailingText: 'English',
                      onTap: () => _showFeatureSnackBar('Language selector'),
                    ),
                    _FlatTile(
                      icon: Icons.headset_mic_outlined,
                      title: 'Help & Live Support',
                      onTap: () => _showFeatureSnackBar('Customer support'),
                    ),
                    _FlatTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Terms',
                      onTap: () => _showFeatureSnackBar('Terms & privacy policy'),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  DangerOutlinedPillButton(
                    text: 'Log Out',
                    icon: Icons.logout_rounded,
                    onPressed: () => _showLogoutDialog(context),
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Soko Mkononi v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Flat header: avatar, name, email — no gradient card, no stat row.
  /// Matches the simpler drawer-style reference while staying a normal
  /// full screen reached the same way as before.
  Widget _buildProfileHeader({
    required User? user,
    required String displayName,
    required String emailText,
  }) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 32,
              key: ValueKey(_imageKey),
              backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: _getProfileImageProvider(user?.profileImage, _profileImage),
              child: (_profileImage == null &&
                      (user?.profileImage == null || user!.profileImage!.trim().isEmpty))
                  ? Text(
                      _initialsFor(
                        username: user?.username ?? '',
                        fullName: user?.fullName,
                        email: emailText,
                      ),
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImageSourcePicker,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1E262C),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                emailText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A flat list of rows with thin dividers — no card border, no shadow.
  Widget _buildFlatSectionList(List<_FlatTile> tiles) {
    return Column(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          tiles[i],
          if (i != tiles.length - 1)
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        ],
      ],
    );
  }

  String _getDisplayName(User? user) {
    if (user?.fullName != null && user!.fullName!.trim().isNotEmpty) {
      return user.fullName!.trim();
    }
    if (user?.username != null && user!.username!.trim().isNotEmpty) {
      return user.username!.trim();
    }
    if (user?.email != null && user!.email.contains('@')) {
      return user.email.split('@').first;
    }
    return 'Customer';
  }

  String _initialsFor({
    required String username,
    String? fullName,
    required String email,
  }) {
    if (fullName != null && fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        final first = parts.first[0];
        final last = parts.length > 1 ? parts.last[0] : '';
        return (first + last).toUpperCase();
      }
    }
    if (username.isNotEmpty) {
      return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
    }
    return email.substring(0, email.length >= 2 ? 2 : 1).toUpperCase();
  }

  ImageProvider? _getProfileImageProvider(String? imageUrl, File? localFile) {
    if (localFile != null) {
      return FileImage(localFile);
    }
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      final resolved = UserModel.resolveImageUrl(imageUrl);
      if (resolved != null) {
        if (resolved.startsWith('data:image/')) {
          try {
            final base64Data = resolved.split(',').last;
            final bytes = base64Decode(base64Data);
            return MemoryImage(bytes);
          } catch (_) {}
        } else if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
          return NetworkImage(resolved);
        }
      }
    }
    return null;
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E262C),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryGreen),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryGreen),
                title: const Text('Choose from Photo Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    final oldImageUrl = context.read<ProfileCubit>().state.user?.profileImage;

    final success =
        await context.read<ProfileCubit>().uploadProfileImage(_profileImage!);

    if (!mounted) return;

    // Evict old and new cached network images.
    _evictNetworkImage(oldImageUrl);
    final newImageUrl = context.read<ProfileCubit>().state.user?.profileImage;
    _evictNetworkImage(newImageUrl);

    if (success) {
      setState(() {
        _profileImage = null; // let state.user.profileImage drive the avatar
        _imageKey++;          // bust the NetworkImage cache
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully!'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final errorMsg =
          context.read<ProfileCubit>().state.error ?? 'Failed to upload image';
      setState(() => _profileImage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await appAuthRepository.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFeatureSnackBar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title tapped'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// A single flat row: icon, title, and an optional trailing chip/text/
/// switch, with no card background or border — matches the minimal,
/// list-style reference design.
class _FlatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  const _FlatTile({
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF334155), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E262C),
                ),
              ),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else ...[
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}