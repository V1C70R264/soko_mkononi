// lib/presentation/screens/become_seller_screen.dart
import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/domain/entities/my_store_entity.dart';
import 'package:e_commerce/presentation/bloc/stores/my_store_bloc.dart';
import 'package:e_commerce/presentation/bloc/stores/my_store_event.dart';
import 'package:e_commerce/presentation/bloc/stores/my_store_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/presentation/widgets/common/app_back_button.dart';

class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyStoreBloc>().add(LoadMyStore());
  }

  Widget _buildContent(BuildContext context, MyStoreState state) {
    final store = state.store;

    void submit(String name, String description) {
      context.read<MyStoreBloc>().add(
            SubmitStoreApplication(name: name, description: description),
          );
    }

    if (store == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StatusBanner(
            icon: Icons.storefront_outlined,
            color: AppTheme.primaryGreen,
            title: 'Sell on Soko Mkononi',
            message: 'Tell us about your store. We review every application '
                'before it goes live.',
          ),
          const SizedBox(height: 20),
          _ApplicationForm(isSubmitting: state.isSubmitting, onSubmit: submit),
        ],
      );
    }

    switch (store.status) {
      case StoreApplicationStatus.pending:
        return _StatusBanner(
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFF59E0B),
          title: 'Application under review',
          message: 'Your application for "${store.name}" is being reviewed. '
              'You will be able to list products once it is approved.',
        );
      case StoreApplicationStatus.approved:
        return _StatusBanner(
          icon: Icons.check_circle_outline_rounded,
          color: AppTheme.primaryGreen,
          title: 'Your store is approved',
          message: '"${store.name}" is approved. Listing products from the '
              'app is coming soon.',
        );
      case StoreApplicationStatus.rejected:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusBanner(
              icon: Icons.cancel_outlined,
              color: Colors.red,
              title: 'Application not approved',
              message: store.rejectionReason.isNotEmpty
                  ? store.rejectionReason
                  : 'Your application was not approved. You can update your '
                      'details and apply again.',
            ),
            const SizedBox(height: 20),
            _ApplicationForm(
              initialName: store.name,
              initialDescription: store.description,
              isSubmitting: state.isSubmitting,
              onSubmit: submit,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Expanded(
                    child: Text(
                      'Become a Seller',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<MyStoreBloc, MyStoreState>(
                // Fires once when a submit fails, and once when it succeeds.
                // It does not fire when a new submit clears the old error.
                listenWhen: (prev, curr) =>
                    (curr.submitError != null &&
                        prev.submitError != curr.submitError) ||
                    (prev.isSubmitting &&
                        !curr.isSubmitting &&
                        curr.submitError == null),
                listener: (context, state) {
                  final message = state.submitError ?? 'Application submitted';
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                },
                builder: (context, state) {
                  if (state.status == MyStoreStatus.initial ||
                      state.status == MyStoreStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == MyStoreStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.error ?? 'Something went wrong'),
                          TextButton(
                            onPressed: () =>
                                context.read<MyStoreBloc>().add(LoadMyStore()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: _buildContent(context, state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _StatusBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationForm extends StatefulWidget {
  final String initialName;
  final String initialDescription;
  final bool isSubmitting;
  final void Function(String name, String description) onSubmit;

  const _ApplicationForm({
    this.initialName = '',
    this.initialDescription = '',
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<_ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<_ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _description = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_name.text.trim(), _description.text.trim());
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            decoration: _decoration('Store name'),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Required';
              if (text.length < 3) return 'Must be at least 3 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _description,
            maxLines: 4,
            decoration: _decoration('What do you sell? (optional)'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: widget.isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Application',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}