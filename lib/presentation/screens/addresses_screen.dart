// lib/presentation/screens/addresses_screen.dart
import 'package:e_commerce/presentation/bloc/address/address_bloc.dart';
import 'package:e_commerce/presentation/bloc/address/address_event.dart';
import 'package:e_commerce/presentation/bloc/address/address_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(LoadAddresses());
  }

  void _openAddForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddAddressSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Addresses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        icon: const Icon(Icons.add),
        label: const Text('Add address'),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AddressLoading || state is AddressInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! AddressLoaded) {
            return const Center(child: Text('Something went wrong'));
          }
          if (state.addresses.isEmpty) {
            return const Center(
              child: Text('No saved addresses yet. Add one to check out.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return Card(
                child: ListTile(
                  title: Text(
                    address.label.isNotEmpty ? address.label : address.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${address.fullName}\n${address.streetAddress}, '
                    '${address.district}, ${address.region}\n'
                    '${address.phoneNumber}',
                  ),
                  isThreeLine: true,
                  trailing: address.isDefault
                      ? const Chip(label: Text('Default'))
                      : TextButton(
                          onPressed: () => context
                              .read<AddressBloc>()
                              .add(SetDefaultAddressEvent(address.id)),
                          child: const Text('Set default'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _region = TextEditingController();
  final _district = TextEditingController();
  final _street = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
    _fullName.dispose();
    _phone.dispose();
    _region.dispose();
    _district.dispose();
    _street.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AddressBloc>().add(AddAddress(
          label: _label.text.trim(),
          fullName: _fullName.text.trim(),
          phoneNumber: _phone.text.trim(),
          region: _region.text.trim(),
          district: _district.text.trim(),
          streetAddress: _street.text.trim(),
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _label,
                decoration: const InputDecoration(labelText: 'Label (e.g. Home)'),
              ),
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone number'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _region,
                decoration: const InputDecoration(labelText: 'Region'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _district,
                decoration: const InputDecoration(labelText: 'District'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _street,
                decoration: const InputDecoration(labelText: 'Street address'),
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}