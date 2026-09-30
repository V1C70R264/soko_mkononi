// lib/domain/usecases/set_default_address.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/address_entity.dart';
import 'package:e_commerce/domain/repositories/address_repository.dart';

class SetDefaultAddress {
  final AddressRepository repository;
  SetDefaultAddress(this.repository);

  Future<Result<AddressEntity>> call(int addressId) =>
      repository.setDefaultAddress(addressId);
}