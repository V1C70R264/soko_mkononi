// lib/data/models/address_model.dart
import 'package:e_commerce/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.label,
    required super.fullName,
    required super.phoneNumber,
    required super.region,
    required super.district,
    required super.streetAddress,
    required super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      label: json['label'] as String? ?? '',
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      region: json['region'] as String,
      district: json['district'] as String,
      streetAddress: json['street_address'] as String,
      isDefault: json['is_default'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'region': region,
      'district': district,
      'street_address': streetAddress,
      // is_default is never sent on create — the backend decides the
      // first address automatically, and set-default is its own endpoint.
    };
  }
}