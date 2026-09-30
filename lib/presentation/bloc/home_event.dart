// presentation/bloc/home_event.dart
abstract class HomeEvent {}

class LoadCategories extends HomeEvent {}

class SelectCategory extends HomeEvent {
  final int categoryId;
  SelectCategory(this.categoryId);
}