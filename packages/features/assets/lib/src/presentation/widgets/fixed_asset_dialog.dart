import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:foundation/foundation.dart';
import '../../../application/application.dart';
import '../../../domain/domain.dart';

/// حوار إضافة/تعديل أصل ثابت مع نموذج كامل
class FixedAssetDialog extends StatefulWidget {
  final FixedAsset? asset;
  final Function(CreateFixedAssetParams) onSave;

  const FixedAssetDialog({
    super.key,
    this.asset,
    required this.onSave,
  });

  @override
  State<FixedAssetDialog> createState() => _FixedAssetDialogState();
}

class _FixedAssetDialogState extends State<FixedAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _costController = TextEditingController();
  final _lifeController = TextEditingController();
  final _salvageController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _fxRateController = TextEditingController(text: '1.0');

  DateTime _purchaseDate = DateTime.now();
  Currency _selectedCurrency = Currency.syp();
  UniqueId? _categoryId;

  @override
  void initState() {
    super.initState();
    if (widget.asset != null) {
      _nameController.text = widget.asset!.name;
      _codeController.text = widget.asset!.code;
      _costController.text = widget.asset!.purchaseCost.amount.toString();
      _lifeController.text = widget.asset!.usefulLifeMonths.toString();
      _salvageController.text = widget.asset!.salvageValue?.amount.toString() ?? '';
      _locationController.text = widget.asset!.location ?? '';
      _notesController.text = widget.asset!.notes ?? '';
      _purchaseDate = widget.asset!.purchaseDate;
      _selectedCurrency = widget.asset!.currency;
      _categoryId = widget.asset!.categoryId;
      _fxRateController.text = widget.asset!.fxRate.rate.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _costController.dispose();
    _lifeController.dispose();
    _salvageController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _fxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.asset == null ? 'إضافة أصل ثابت' : 'تعديل أصل ثابت'),
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
                    labelText: 'اسم الأصل *',
                    hintText: 'مثال: جرة غاز صناعية',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اسم الأصول مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // الكود
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'كود الأصل',
                    hintText: 'يتم التوليد تلقائياً إذا تركته فارغاً',
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),

                // التصنيف
                _buildCategoryDropdown(),
                const SizedBox(height: 16),

                // التكلفة والعملة في صف واحد
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'تكلفة الشراء *',
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
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'أدخل مبلغ صحيح';
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

                // سعر الصرف (يظهر فقط للعملات الأجنبية)
                if (_selectedCurrency.code != 'SYP')
                  TextFormField(
                    controller: _fxRateController,
                    decoration: const InputDecoration(
                      labelText: 'سعر الصرف *',
                      hintText: 'مثال: 12500 (الدولار بالليرة)',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (_selectedCurrency.code != 'SYP') {
                        if (value == null || value.isEmpty) {
                          return 'سعر الصرف مطلوب للعملات الأجنبية';
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

                // تاريخ الشراء
                _buildDatePicker(),
                const SizedBox(height: 16),

                // العمر الإنتاجي والقيمة المتبقية
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lifeController,
                        decoration: const InputDecoration(
                          labelText: 'العمر (بالشهور) *',
                          hintText: '12',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'العمر الإنتاجي مطلوب';
                          }
                          final months = int.tryParse(value);
                          if (months == null || months <= 0) {
                            return 'أدخل رقماً صحيحاً';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _salvageController,
                        decoration: const InputDecoration(
                          labelText: 'القيمة المتبقية',
                          hintText: '0',
                          prefixIcon: Icon(Icons.money_off),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // الموقع
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'الموقع',
                    hintText: 'مثال: المستودع الرئيسي',
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
          child: Text(widget.asset == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    // TODO: Fetch categories from repository
    return DropdownButtonFormField<UniqueId?>(
      value: _categoryId,
      decoration: const InputDecoration(
        labelText: 'التصنيف *',
        prefixIcon: Icon(Icons.category),
      ),
      hint: const Text('اختر التصنيف'),
      items: [
        // Placeholder items - replace with actual categories
        DropdownMenuItem(
          value: UniqueId.generate(),
          child: const Text('معدات'),
        ),
        DropdownMenuItem(
          value: UniqueId.generate(),
          child: const Text('أجهزة'),
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

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _purchaseDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _purchaseDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'تاريخ الشراء *',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          '${_purchaseDate.year}-${_purchaseDate.month.toString().padLeft(2, '0')}-${_purchaseDate.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final params = CreateFixedAssetParams(
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        categoryId: _categoryId ?? UniqueId.generate(),
        purchaseDate: _purchaseDate,
        purchaseCost: Money.fromDouble(
          double.parse(_costController.text),
          _selectedCurrency,
        ),
        currency: _selectedCurrency,
        fxRate: MoneyFxRate(
          fromCurrency: _selectedCurrency,
          toCurrency: Currency.syp(),
          rate: double.parse(_fxRateController.text),
          rateDate: DateTime.now(),
        ),
        usefulLifeMonths: int.parse(_lifeController.text),
        salvageValue: _salvageController.text.isNotEmpty
            ? Money.fromDouble(
                double.parse(_salvageController.text),
                _selectedCurrency,
              )
            : null,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdBy: 'current_user', // TODO: Get from auth
      );

      widget.onSave(params);
      Navigator.pop(context);
    }
  }
}
