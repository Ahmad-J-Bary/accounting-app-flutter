import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:customers/customers.dart';
import 'package:customers/application/use_cases/create_customer.dart';
import 'package:customers/presentation/state/customers_provider.dart';

class CustomerForm extends ConsumerStatefulWidget {
  final Customer? customer;

  const CustomerForm({super.key, this.customer});

  @override
  ConsumerState<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _creditLimitController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _codeController.text = widget.customer!.code;
      _nameController.text = widget.customer!.name;
      _emailController.text = widget.customer!.email ?? '';
      _phoneController.text = widget.customer!.phone ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _creditLimitController.text = widget.customer!.creditLimit.toString();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final params = CreateCustomerParams(
        code: _codeController.text,
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        creditLimit: double.tryParse(_creditLimitController.text) ?? 0,
      );

      final useCase = ref.read(createCustomerUseCaseProvider);
      final result = await useCase(params);

      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.toString()}')),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Customer saved successfully')),
            );
            Navigator.of(context).pop();
            ref.invalidate(customersListProvider);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppInput(
            label: 'Code *',
            controller: _codeController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Code is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Name *',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Invalid email format';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Phone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Address',
            controller: _addressController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Credit Limit',
            controller: _creditLimitController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  type: AppButtonType.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Save',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
