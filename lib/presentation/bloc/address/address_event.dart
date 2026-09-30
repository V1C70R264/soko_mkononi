// lib/presentation/bloc/address/address_event.dart
abstract class AddressEvent {}

class LoadAddresses extends AddressEvent {}

class AddAddress extends AddressEvent {
  final String label;
  final String fullName;
  final String phoneNumber;
  final String region;
  final String district;
  final String streetAddress;

  AddAddress({
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.region,
    required this.district,
    required this.streetAddress,
  });
}

class SetDefaultAddressEvent extends AddressEvent {
  final int addressId;
  SetDefaultAddressEvent(this.addressId);
}