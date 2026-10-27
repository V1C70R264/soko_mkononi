// lib/presentation/bloc/stores/stores_event.dart
abstract class StoresEvent {}

class LoadStores extends StoresEvent {
  final String query;
  LoadStores([this.query = '']);
}

class LoadMoreStores extends StoresEvent {}