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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1E262C),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF1E262C),
                size: 20,
              ),
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
          final usernameText = user?.username != null && user!.username!.isNotEmpty
              ? '@${user.username}'
              : '@user';
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dribbble-inspired Modern Profile Hero Card
                  _buildProfileHeroCard(
                    user: user,
                    displayName: displayName,
                    usernameText: usernameText,
                    emailText: emailText,
                    phoneText: phoneText,
                  ),
                  const SizedBox(height: 24),

                  // Quick Action Stats Bar
                  _buildQuickStatsSection(context),
                  const SizedBox(height: 24),

                  // Shopping & Account Sections
                  const Text(
                    'Shopping & Orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E262C),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGroupedCard([
                    _buildSettingsTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
                      subtitle: 'Track, return, or reorder items',
                      badgeText: '2 Active',
                      badgeColor: AppTheme.primaryGreen,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const OrdersScreen()),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Wishlist & Favorites',
                      subtitle: 'Saved products you love',
                      badgeText: '5 Items',
                      badgeColor: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Shipping Addresses',
                      subtitle: 'Manage delivery addresses',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressesScreen()),
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Methods',
                      subtitle: 'Cards, M-Pesa & Mobile wallets',
                      onTap: () => _showFeatureSnackBar('Payment methods feature'),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E262C),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGroupedCard([
                    _buildSettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Details',
                      subtitle: 'Update your name, email & phone',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Security & Password',
                      subtitle: 'Change password & security options',
                      onTap: () => _showFeatureSnackBar('Security settings'),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Promotions, orders & update alerts',
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

                  const SizedBox(height: 24),
                  const Text(
                    'Preferences & Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E262C),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGroupedCard([
                    _buildSettingsTile(
                      icon: Icons.language_rounded,
                      title: 'App Language',
                      subtitle: 'English (US) / Swahili',
                      trailingText: 'English',
                      onTap: () => _showFeatureSnackBar('Language selector'),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.headset_mic_outlined,
                      title: 'Help & Live Support',
                      subtitle: '24/7 customer care & FAQs',
                      onTap: () => _showFeatureSnackBar('Customer support'),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Terms',
                      subtitle: 'Data protection and policies',
                      onTap: () => _showFeatureSnackBar('Terms & privacy policy'),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // Logout Button
                  // Logout Button (Using reusable DangerOutlinedPillButton)
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

  /// Modern Gradient Hero Card with Avatar & Camera Upload
  Widget _buildProfileHeroCard({
    required User? user,
    required String displayName,
    required String usernameText,
    required String emailText,
    required String phoneText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E262C),
            Color(0xFF2D3748),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with camera icon wired to backend
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryGreen, Colors.white],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      key: ValueKey(_imageKey),
                      backgroundColor: Colors.white,
                      backgroundImage: _getProfileImageProvider(user?.profileImage, _profileImage),
                      child: (_profileImage == null && (user?.profileImage == null || user!.profileImage!.trim().isEmpty))
                          ? Text(
                              _initialsFor(
                                username: user?.username ?? '',
                                fullName: user?.fullName,
                                email: emailText,
                              ),
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourcePicker,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // User Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: AppTheme.primaryGreen,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usernameText,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Gold Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF334155), thickness: 1),
          const SizedBox(height: 8),
          // Email and Phone chips
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        emailText,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        phoneText,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4 Quick Actions Grid (Orders, Wishlist, Cart, Points)
  Widget _buildQuickStatsSection(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.local_mall_outlined,
          title: 'My Orders',
          value: '12 Items',
          color: const Color(0xFF3B82F6),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          icon: Icons.favorite_border_rounded,
          title: 'Wishlist',
          value: '5 Saved',
          color: const Color(0xFFEC4899),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          icon: Icons.shopping_cart_outlined,
          title: 'My Cart',
          value: '3 Items',
          color: AppTheme.primaryGreen,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          icon: Icons.stars_rounded,
          title: 'Rewards',
          value: '1,250 Pts',
          color: const Color(0xFFF59E0B),
          onTap: () => _showFeatureSnackBar('Reward points & vouchers'),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E262C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// White Rounded Group Card
  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 64,
    );
  }

  /// Reusable Settings Tile
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    String? trailingText,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF334155), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E262C),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: trailingWidget ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (trailingText != null)
                Text(
                  trailingText,
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
          ),
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
