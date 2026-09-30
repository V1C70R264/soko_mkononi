import 'package:e_commerce/domain/entities/category_entity.dart';
import 'package:e_commerce/domain/repositories/home_repository.dart';
import 'package:e_commerce/core/utils/result.dart';

class GetCategories {
  final HomeRepository repository;
  GetCategories(this.repository);
  Future<Result<List<CategoryEntity>>> call() => repository.getCategories();
}