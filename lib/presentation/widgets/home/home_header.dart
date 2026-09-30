import 'package:e_commerce/core/utils/profile_image_utils.dart';
import 'package:e_commerce/presentation/data/home_mock_data.dart';
import 'package:e_commerce/presentation/widgets/home/category_item.dart';
import 'package:e_commerce/presentation/widgets/home/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/domain/entities/category_entity.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final int avatarCacheVersion;
  final List<CategoryEntity> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onCategorySelected;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
    this.avatarCacheVersion = 0,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.onNotificationTap,
    this.onSearchTap,
    this.onFilterTap,
  });

  Widget _buildAvatarWidget(String url) {
    const fallback = Icon(
      Icons.person,
      color: Color(0xFF64748B),
      size: 26,
    );

    return ProfileImageUtils.networkImage(
      url: url,
      width: 48,
      height: 48,
      cacheVersion: avatarCacheVersion,
      fallback: fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userName.trim().isNotEmpty ? userName : 'Guest';
    final topPadding = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 10,
        left: HomeLayout.horizontalPadding,
        right: HomeLayout.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildAvatarWidget(avatarUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hi,',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onNotificationTap,
                    customBorder: const CircleBorder(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.solidBell,
                          color: Color(0xFF0F172A),
                          size: 19,
                        ),
                        Positioned(
                          top: 10,
                          right: 11,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF26AD71),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SearchBarWidget(
            onTap: onSearchTap,
            onFilterTap: onFilterTap,
          ),
          const SizedBox(height: 24),
          const Text(
            'Categories',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryItem(
                  category: category,
                  isSelected: selectedCategoryId == category.id,
                  onTap: () => onCategorySelected(category.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}