// lib/data/repositories/address_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/data/datasources/remote/address_remote_datasource.dart';
import 'package:e_commerce/domain/entities/address_entity.dart';
import 'package:e_commerce/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  AddressRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<AddressEntity>>> getAddresses() async {
    try {
      final addresses = await remoteDataSource.getAddresses();
      return Success(addresses);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load addresses'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<AddressEntity>> createAddress({
    required String label,
    required String fullName,
    required String phoneNumber,
    required String region,
    required String district,
    required String streetAddress,
  }) async {
    try {
      final address = await remoteDataSource.createAddress({
        'label': label,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'region': region,
        'district': district,
        'street_address': streetAddress,
      });
      return Success(address);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to save address'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<AddressEntity>> setDefaultAddress(int addressId) async {
    try {
      final address = await remoteDataSource.setDefaultAddress(addressId);
      return Success(address);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to set default address'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}