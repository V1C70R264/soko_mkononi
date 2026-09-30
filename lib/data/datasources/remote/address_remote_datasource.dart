// lib/data/datasources/remote/address_remote_datasource.dart
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> createAddress(Map<String, dynamic> body);
  Future<AddressModel> setDefaultAddress(int addressId);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient apiClient;
  AddressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await apiClient.dio.get('/addresses/');
    // AddressViewSet sets no explicit pagination_class, so the response
    // shape depends on the project's global DEFAULT_PAGINATION_CLASS.
    // Handle both: a plain list, or a paginated {"results": [...]} object.
    final data = response.data;
    final List rawList = data is List ? data : data['results'] as List;
    return rawList
        .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> body) async {
    final response = await apiClient.dio.post('/addresses/', data: body);
    return AddressModel.fromJson(response.data);
  }

  @override
  Future<AddressModel> setDefaultAddress(int addressId) async {
    final response =
        await apiClient.dio.post('/addresses/$addressId/set-default/');
    return AddressModel.fromJson(response.data);
  }
}