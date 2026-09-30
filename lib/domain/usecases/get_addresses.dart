// lib/domain/usecases/get_addresses.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/address_entity.dart';
import 'package:e_commerce/domain/repositories/address_repository.dart';

class GetAddresses {
  final AddressRepository repository;
  GetAddresses(this.repository);

  Future<Result<List<AddressEntity>>> call() => repository.getAddresses();
}