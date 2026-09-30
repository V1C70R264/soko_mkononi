// lib/domain/repositories/address_repository.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/address_entity.dart';

abstract class AddressRepository {
  Future<Result<List<AddressEntity>>> getAddresses();

  Future<Result<AddressEntity>> createAddress({
    required String label,
    required String fullName,
    required String phoneNumber,
    required String region,
    required String district,
    required String streetAddress,
  });

  Future<Result<AddressEntity>> setDefaultAddress(int addressId);
}