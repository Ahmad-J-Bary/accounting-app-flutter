import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:products/products.dart';
import 'package:products/application/use_cases/create_product.dart';
import 'package:products/presentation/state/products_provider.dart';

class ProductForm extends ConsumerStatefulWidget {
  final Product? product;

  const ProductForm({super.key, this.product});

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _costController = TextEditingController();
  final _unitController = TextEditingController();
  final _taxRateController = TextEditingController();
  ProductType _selectedType = ProductType.inventory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _codeController.text = widget.product!.code;
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _salePriceController.text = widget.product!.salePrice.toString();
      _costController.text = widget.product!.cost.toString();
      _unitController.text = widget.product!.unit ?? '';
      _taxRateController.text = widget.product!.taxRate.toString();
      _selectedType = widget.product!.type;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _costController.dispose();
    _unitController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final params = CreateProductParams(
        code: _codeController.text,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        type: _selectedType,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0,
        cost: double.tryParse(_costController.text) ?? 0,
        unit: _unitController.text.isEmpty ? null : _unitController.text,
        taxRate: double.tryParse(_taxRateController.text) ?? 0,
      );

      final useCase = ref.read(createProductUseCaseProvider);
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
              const SnackBar(content: Text('Product saved successfully')),
            );
            Navigator.of(context).pop();
            ref.invalidate(productsListProvider);
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
          DropdownButtonFormField<ProductType>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Type',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: ProductType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedType = value!);
            },
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Description',
            controller: _descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppInput(
                  label: 'Purchase Price',
                  controller: _purchasePriceController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppInput(
                  label: 'Sale Price',
                  controller: _salePriceController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppInput(
                  label: 'Cost',
                  controller: _costController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppInput(
                  label: 'Tax Rate',
                  controller: _taxRateController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Unit',
            controller: _unitController,
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
