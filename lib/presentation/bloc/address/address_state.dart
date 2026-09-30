// lib/presentation/bloc/address/address_state.dart
import 'package:e_commerce/domain/entities/address_entity.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;
  AddressLoaded(this.addresses);

  AddressEntity? get defaultAddress {
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return addresses.isEmpty ? null : addresses.first;
  }
}

class AddressError extends AddressState {
  final String message;
  AddressError(this.message);
}