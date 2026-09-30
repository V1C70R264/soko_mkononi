// data/models/product_model.dart
import 'package:e_commerce/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.stockQuantity,
    required super.categoryId,
    required super.imageUrl,
    required super.isFavorited,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      // price arrives as a JSON string (DecimalField serializes to string) — parse explicitly
      price: double.parse(json['price'] as String),
      stockQuantity: json['stock_quantity'] as int,
      categoryId: json['category_details']['id'] as int,
      imageUrl: json['image'] as String? ?? '',
      isFavorited: json['is_favorited'] as bool? ?? false,
    );
  }
}




// enum ProductCategory {
//   phones,
//   laptops,
//   tablets,
//   headphones,
//   speakers,
//   cameras,
//   gaming,
//   smartwatches,
//   smarthome,
//   other,
// }

// class Product {
//   final String id;
//   final String title;
//   final String description;
//   final String imageUrl;
//   final double price;
//   final ProductCategory category;
//   bool isFavourite;

//   Product({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.imageUrl,
//     required this.price,
//     required this.category,
//     this.isFavourite = false,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'].toString(),
//       title: json['title'],
//       description: json['description'],
//       imageUrl: json['image'],
//       price: double.parse(json['price'].toString()),
//       category: _categoryFromString(json['category']),
//     );
//   }

//   static ProductCategory _categoryFromString(String category) {
//     switch (category) {
//       case 'phones':
//         return ProductCategory.phones;
//       case 'laptops':
//         return ProductCategory.laptops;
//       case 'tablets':
//         return ProductCategory.tablets;
//       case 'headphones':
//         return ProductCategory.headphones;
//       case 'speakers':
//         return ProductCategory.speakers;
//       case 'cameras':
//         return ProductCategory.cameras;
//       case 'gaming':
//         return ProductCategory.gaming;
//       case 'smartwatches':
//         return ProductCategory.smartwatches;
//       case 'smarthome':
//         return ProductCategory.smarthome;
//       default:
//         return ProductCategory.other;
//     }
//   }
// } 

