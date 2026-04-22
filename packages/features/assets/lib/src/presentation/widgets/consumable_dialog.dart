import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:foundation/foundation.dart';
import '../../../application/application.dart';
import '../../../domain/domain.dart';

/// حوار إضافة/تعديل مستهلك مع نموذج كامل
class ConsumableDialog extends StatefulWidget {
  final ConsumableItem? item;
  final Function(CreateConsumableParams) onSave;

  const ConsumableDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<ConsumableDialog> createState() => _ConsumableDialogState();
}

class _ConsumableDialogState extends State<ConsumableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _fxRateController = TextEditingController(text: '1.0');
  final _unitController = TextEditingController(text: 'piece');

  Currency _selectedCurrency = Currency.syp();
  UniqueId? _categoryId;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _codeController.text = widget.item!.code;
      _quantityController.text = widget.item!.quantityOnHand.value.toString();
      _unitCostController.text = widget.item!.unitCost.amount.toString();
      _locationController.text = widget.item!.location ?? '';
      _notesController.text = widget.item!.notes ?? '';
      _selectedCurrency = widget.item!.currency;
      _categoryId = widget.item!.categoryId;
      _fxRateController.text = widget.item!.fxRate.rate.toString();
      _unitController.text = widget.item!.unitOfMeasure.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _fxRateController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'إضافة مستهلك' : 'تعديل مستهلك'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الاسم
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستهلك *',
                    hintText: 'مثال: تعبئة، ورق سندويش',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اسم المستهلك مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // الكود
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'كود المستهلك',
                    hintText: 'يتم التوليد تلقائياً إذا تركته فارغاً',
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),

                // التصنيف
                _buildCategoryDropdown(),
                const SizedBox(height: 16),

                // الكمية والوحدة
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'الكمية *',
                          hintText: '100',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الكمية مطلوبة';
                          }
                          final qty = double.tryParse(value);
                          if (qty == null || qty < 0) {
                            return 'أدخل كمية صحيحة';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'الوحدة',
                          hintText: 'piece',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // التكلفة والعملة
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _unitCostController,
                        decoration: const InputDecoration(
                          labelText: 'تكلفة الوحدة *',
                          hintText: '50',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'التكلفة مطلوبة';
                          }
                          final cost = double.tryParse(value);
                          if (cost == null || cost < 0) {
                            return 'أدخل تكلفة صحيحة';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCurrencyDropdown(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // سعر الصرف
                if (_selectedCurrency.code != 'SYP')
                  TextFormField(
                    controller: _fxRateController,
                    decoration: const InputDecoration(
                      labelText: 'سعر الصرف *',
                      hintText: 'مثال: 12500',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (_selectedCurrency.code != 'SYP') {
                        if (value == null || value.isEmpty) {
                          return 'سعر الصرف مطلوب';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate <= 0) {
                          return 'أدخل سعر صرف صحيح';
                        }
                      }
                      return null;
                    },
                  ),
                if (_selectedCurrency.code != 'SYP') const SizedBox(height: 16),

                // الموقع
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'الموقع',
                    hintText: 'مثال: مستودع المواد الخام',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),

                // الملاحظات
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.item == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<UniqueId?>(
      value: _categoryId,
      decoration: const InputDecoration(
        labelText: 'التصنيف *',
        prefixIcon: Icon(Icons.category),
      ),
      hint: const Text('اختر التصنيف'),
      items: [
        DropdownMenuItem(
          value: UniqueId.generate(),
          child: const Text('مواد تعبئة'),
        ),
        DropdownMenuItem(
          value: UniqueId.generate(),
          child: const Text('مواد مطبخ'),
        ),
        DropdownMenuItem(
          value: UniqueId.generate(),
          child: const Text('مستلزمات تشغيل'),
        ),
      ],
      onChanged: (value) => setState(() => _categoryId = value),
      validator: (value) {
        if (value == null) {
          return 'التصنيف مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<Currency>(
      value: _selectedCurrency,
      decoration: const InputDecoration(
        labelText: 'العملة',
        prefixIcon: Icon(Icons.currency_exchange),
      ),
      items: [
        DropdownMenuItem(
          value: Currency.syp(),
          child: const Text('ل.س'),
        ),
        DropdownMenuItem(
          value: Currency.usd(),
          child: const Text('\$'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCurrency = value);
        }
      },
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final params = CreateConsumableParams(
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        categoryId: _categoryId ?? UniqueId.generate(),
        initialQuantity: Quantity(
          double.parse(_quantityController.text),
          _unitController.text.trim().isNotEmpty
              ? _unitController.text.trim()
              : 'piece',
        ),
        unitOfMeasure: Quantity(1, _unitController.text.trim().isNotEmpty
            ? _unitController.text.trim()
            : 'piece'),
        unitCost: Money.fromDouble(
          double.parse(_unitCostController.text),
          _selectedCurrency,
        ),
        currency: _selectedCurrency,
        fxRate: MoneyFxRate(
          fromCurrency: _selectedCurrency,
          toCurrency: Currency.syp(),
          rate: double.parse(_fxRateController.text),
          rateDate: DateTime.now(),
        ),
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdBy: 'current_user',
      );

      widget.onSave(params);
      Navigator.pop(context);
    }
  }
}
