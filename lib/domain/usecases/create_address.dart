// lib/domain/usecases/create_address.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/address_entity.dart';
import 'package:e_commerce/domain/repositories/address_repository.dart';

class CreateAddress {
  final AddressRepository repository;
  CreateAddress(this.repository);

  Future<Result<AddressEntity>> call({
    required String label,
    required String fullName,
    required String phoneNumber,
    required String region,
    required String district,
    required String streetAddress,
  }) {
    return repository.createAddress(
      label: label,
      fullName: fullName,
      phoneNumber: phoneNumber,
      region: region,
      district: district,
      streetAddress: streetAddress,
    );
  }
}