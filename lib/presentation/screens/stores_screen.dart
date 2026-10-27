// lib/presentation/screens/stores_screen.dart
import 'dart:async';

import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/domain/entities/store_entity.dart';
import 'package:e_commerce/presentation/bloc/stores/stores_bloc.dart';
import 'package:e_commerce/presentation/bloc/stores/stores_event.dart';
import 'package:e_commerce/presentation/bloc/stores/stores_state.dart';
import 'package:e_commerce/presentation/screens/store_products_screen.dart';
import 'package:e_commerce/presentation/widgets/store/store_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/core/theme/app_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:e_commerce/presentation/widgets/common/app_back_button.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  static const _loadMoreThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    context.read<StoresBloc>().add(LoadStores());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<StoresBloc>().add(LoadMoreStores());
    }
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<StoresBloc>().add(LoadStores(query.trim()));
    });
  }

    void _openStore(StoreEntity store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreProductsScreen(
          storeId: store.id,
          storeName: store.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: [
                 const AppBackButton(),
                  const Expanded(
                    child: Text(
                      'All Sellers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                onChanged: _onQueryChanged,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: HugeIcon(
                      icon: AppIcons.search,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<StoresBloc, StoresState>(
                builder: (context, state) {
                  if (state.status == StoresStatus.initial ||
                      state.status == StoresStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == StoresStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.error ?? 'Something went wrong'),
                          TextButton(
                            onPressed: () => context
                                .read<StoresBloc>()
                                .add(LoadStores(state.query)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state.stores.isEmpty) {
                    return const Center(child: Text('No sellers found'));
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: state.stores.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == state.stores.length) {
                        return state.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }

                      final store = state.stores[index];
                      return _StoreTile(
                        store: store,
                        onTap: () => _openStore(store),
                        buttonColor: scheme.primary,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  final StoreEntity store;
  final VoidCallback onTap;
  final Color buttonColor;

  const _StoreTile({
    required this.store,
    required this.onTap,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            StoreAvatar(name: store.name, logoUrl: store.logoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    store.productCount == 1
                        ? '1 product'
                        : '${store.productCount} products',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'View Store',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}