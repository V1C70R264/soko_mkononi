// lib/presentation/bloc/address/address_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/get_addresses.dart';
import 'package:e_commerce/domain/usecases/create_address.dart';
import 'package:e_commerce/domain/usecases/set_default_address.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddresses getAddresses;
  final CreateAddress createAddress;
  final SetDefaultAddress setDefaultAddress;

  AddressBloc(this.getAddresses, this.createAddress, this.setDefaultAddress)
      : super(AddressInitial()) {
    on<LoadAddresses>(_onLoad);
    on<AddAddress>(_onAdd);
    on<SetDefaultAddressEvent>(_onSetDefault);
  }

  Future<void> _onLoad(LoadAddresses event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    final result = await getAddresses();
    result.fold(
      (addresses) => emit(AddressLoaded(addresses)),
      (message) => emit(AddressError(message)),
    );
  }

  Future<void> _onAdd(AddAddress event, Emitter<AddressState> emit) async {
    final result = await createAddress(
      label: event.label,
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      region: event.region,
      district: event.district,
      streetAddress: event.streetAddress,
    );

    result.fold(
      (_) => add(LoadAddresses()),
      (message) => emit(AddressError(message)),
    );
  }

  Future<void> _onSetDefault(
    SetDefaultAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    final result = await setDefaultAddress(event.addressId);
    result.fold(
      (_) => add(LoadAddresses()),
      (message) => emit(AddressError(message)),
    );
  }
}