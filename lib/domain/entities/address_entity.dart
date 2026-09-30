// lib/domain/entities/address_entity.dart
import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final int id;
  final String label;
  final String fullName;
  final String phoneNumber;
  final String region;
  final String district;
  final String streetAddress;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.region,
    required this.district,
    required this.streetAddress,
    required this.isDefault,
  });

  @override
  List<Object?> get props =>
      [id, label, fullName, phoneNumber, region, district, streetAddress, isDefault];
}