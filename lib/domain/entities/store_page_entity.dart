// lib/domain/entities/store_page_entity.dart
import 'package:equatable/equatable.dart';
import 'store_entity.dart';

class StorePageEntity extends Equatable {
  final List<StoreEntity> stores;
  final bool hasMore;
  final String? nextCursor;

  const StorePageEntity({
    required this.stores,
    required this.hasMore,
    required this.nextCursor,
  });

  @override
  List<Object?> get props => [stores, hasMore, nextCursor];
}