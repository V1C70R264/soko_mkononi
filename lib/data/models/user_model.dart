import 'package:e_commerce/core/config/api_config.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString(),
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString(),
      phoneNumber: json['phone']?.toString() ??
          json['phone_number']?.toString() ??
          json['phoneNumber']?.toString(),
      profileImage: resolveImageUrl(
        json['profile_image'] ??
            json['avatar_url'] ??
            json['avatar'] ??
            json['profile_picture'] ??
            json['image'],
      ),
    );
  }

  static String? resolveImageUrl(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      value = value['url'] ?? value['path'] ?? value['src'] ?? value['file'];
      if (value == null) return null;
    }
    final url = value.toString().trim();
    if (url.isEmpty || url == 'null') return null;
    if (url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('data:image/')) {
      return url;
    }

    final apiBase = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final origin = apiBase.replaceAll(RegExp(r'/api/v1$'), '');
    return url.startsWith('/') ? '$origin$url' : '$origin/$url';
  }
}
