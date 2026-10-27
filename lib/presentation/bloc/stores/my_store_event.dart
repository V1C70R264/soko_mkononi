// lib/presentation/bloc/stores/my_store_event.dart
abstract class MyStoreEvent {}

class LoadMyStore extends MyStoreEvent {}

class SubmitStoreApplication extends MyStoreEvent {
  final String name;
  final String description;
  SubmitStoreApplication({required this.name, required this.description});
}