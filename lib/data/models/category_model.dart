import '../../domain/entities/category_entity.dart';
class CategoryModel extends CategoryEntity {
  CategoryModel({required super.id, required super.name, required super.description});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}