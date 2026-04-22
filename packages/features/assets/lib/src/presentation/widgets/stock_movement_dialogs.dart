import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:foundation/foundation.dart';
import '../../../application/application.dart';
import '../../../domain/domain.dart';

/// حوار صرف مستهلك
class IssueConsumableDialog extends StatefulWidget {
  final ConsumableItem item;
  final Function(IssueConsumableParams) onIssue;

  const IssueConsumableDialog({
    super.key,
    required this.item,
    required this.onIssue,
  });

  @override
  State<IssueConsumableDialog> createState() => _IssueConsumableDialogState();
}

class _IssueConsumableDialogState extends State<IssueConsumableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _departmentController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _issueDate = DateTime.now();

  @override
  void dispose() {
    _quantityController.dispose();
    _departmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('صرف: ${widget.item.name}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات المخزون
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المخزون المتاح',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${widget.item.quantityOnHand.value.toStringAsFixed(0)} ${widget.item.unitOfMeasure.unit}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'القيمة: ${widget.item.totalCost.amount.toStringAsFixed(0)} ل.س',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // الكمية
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'الكمية المراد صرفها *',
                    hintText: 'أقصى: ${widget.item.quantityOnHand.value.toStringAsFixed(0)}',
                    prefixIcon: const Icon(Icons.remove_circle_outline),
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
                    if (qty == null || qty <= 0) {
                      return 'أدخل كمية صحيحة';
                    }
                    if (qty > widget.item.quantityOnHand.value) {
                      return 'الكمية أكبر من المخزون المتاح';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // الجهة المستفيدة
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'الجهة المستفيدة *',
                    hintText: 'مثال: مطبخ، تعبئة، صالة',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الجهة المستفيدة مطلوبة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // تاريخ الصرف
                _buildDatePicker(),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: const Text('صرف'),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _issueDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) {
          setState(() => _issueDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'تاريخ الصرف *',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          '${_issueDate.year}-${_issueDate.month.toString().padLeft(2, '0')}-${_issueDate.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final params = IssueConsumableParams(
        consumableId: widget.item.id,
        quantity: Quantity(
          double.parse(_quantityController.text),
          widget.item.unitOfMeasure.unit,
        ),
        issueDate: _issueDate,
        department: _departmentController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        issuedBy: 'current_user',
      );

      widget.onIssue(params);
      Navigator.pop(context);
    }
  }
}

/// حوار استلام مستهلك
class ReceiveConsumableDialog extends StatefulWidget {
  final ConsumableItem item;
  final Function(ReceiveConsumableParams) onReceive;

  const ReceiveConsumableDialog({
    super.key,
    required this.item,
    required this.onReceive,
  });

  @override
  State<ReceiveConsumableDialog> createState() => _ReceiveConsumableDialogState();
}

class _ReceiveConsumableDialogState extends State<ReceiveConsumableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  final _fxRateController = TextEditingController(text: '1.0');

  DateTime _receiveDate = DateTime.now();
  Currency _selectedCurrency = Currency.syp();

  @override
  void initState() {
    super.initState();
    // افتراضياً استخدم سعر التكلفة الحالي
    _unitCostController.text = widget.item.unitCost.amount.toString();
    _selectedCurrency = widget.item.currency;
    if (_selectedCurrency.code != 'SYP') {
      _fxRateController.text = widget.item.fxRate.rate.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    _fxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('استلام: ${widget.item.name}'),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات المخزون الحالي
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المخزون الحالي',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${widget.item.quantityOnHand.value.toStringAsFixed(0)} ${widget.item.unitOfMeasure.unit}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'متوسط التكلفة: ${widget.item.unitCost.amount.toStringAsFixed(2)} ل.س',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // الكمية
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'الكمية المراد استلامها *',
                    hintText: '100',
                    prefixIcon: Icon(Icons.add_circle_outline),
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
                    if (qty == null || qty <= 0) {
                      return 'أدخل كمية صحيحة';
                    }
                    return null;
                  },
                  autofocus: true,
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

                // المورد
                TextFormField(
                  controller: _supplierController,
                  decoration: const InputDecoration(
                    labelText: 'المورد (اختياري)',
                    hintText: 'اسم المورد',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),

                // تاريخ الاستلام
                _buildDatePicker(),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('استلام'),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<Currency>(
      value: _selectedCurrency,
      decoration: const InputDecoration(
        labelText: 'العملة',
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
          initialDate: _receiveDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) {
          setState(() => _receiveDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'تاريخ الاستلام *',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          '${_receiveDate.year}-${_receiveDate.month.toString().padLeft(2, '0')}-${_receiveDate.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final params = ReceiveConsumableParams(
        consumableId: widget.item.id,
        quantity: Quantity(
          double.parse(_quantityController.text),
          widget.item.unitOfMeasure.unit,
        ),
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
        receiveDate: _receiveDate,
        supplierName: _supplierController.text.trim().isNotEmpty
            ? _supplierController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        receivedBy: 'current_user',
      );

      widget.onReceive(params);
      Navigator.pop(context);
    }
  }
}

/// حوار بيع/استبعاد أصل ثابت
class DisposeAssetDialog extends StatefulWidget {
  final FixedAsset asset;
  final Function(DisposeFixedAssetParams) onDispose;

  const DisposeAssetDialog({
    super.key,
    required this.asset,
    required this.onDispose,
  });

  @override
  State<DisposeAssetDialog> createState() => _DisposeAssetDialogState();
}

class _DisposeAssetDialogState extends State<DisposeAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _buyerController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _disposalDate = DateTime.now();
  bool _isSale = false;

  @override
  void dispose() {
    _priceController.dispose();
    _buyerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('استبعاد/بيع: ${widget.asset.name}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات الأصل
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'معلومات الأصل',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('التكلفة الأصلية', '${widget.asset.purchaseCost.amount.toStringAsFixed(0)} ل.س'),
                      _buildInfoRow('مجمع الاهلاك', '${widget.asset.accumulatedDepreciation.amount.toStringAsFixed(0)} ل.س'),
                      _buildInfoRow('القيمة الدفترية', '${widget.asset.netBookValue.amount.toStringAsFixed(0)} ل.س'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // نوع العملية
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('استبعاد'),
                        selected: !_isSale,
                        onSelected: (selected) {
                          if (selected) setState(() => _isSale = false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('بيع'),
                        selected: _isSale,
                        onSelected: (selected) {
                          if (selected) setState(() => _isSale = true);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // سعر البيع (يظهر فقط إذا كان البيع)
                if (_isSale)
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر البيع *',
                      hintText: 'مثال: 5000',
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (_isSale) {
                        if (value == null || value.isEmpty) {
                          return 'سعر البيع مطلوب';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price < 0) {
                          return 'أدخل سعر صحيح';
                        }
                      }
                      return null;
                    },
                  ),
                if (_isSale) const SizedBox(height: 16),

                // المشتري (يظهر فقط إذا كان البيع)
                if (_isSale)
                  TextFormField(
                    controller: _buyerController,
                    decoration: const InputDecoration(
                      labelText: 'المشتري',
                      hintText: 'اسم المشتري',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                if (_isSale) const SizedBox(height: 16),

                // تاريخ العملية
                _buildDatePicker(),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSale ? Colors.blue : Colors.red,
          ),
          child: Text(_isSale ? 'بيع' : 'استبعاد'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _disposalDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) {
          setState(() => _disposalDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'تاريخ العملية *',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          '${_disposalDate.year}-${_disposalDate.month.toString().padLeft(2, '0')}-${_disposalDate.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final params = DisposeFixedAssetParams(
        id: widget.asset.id,
        disposalDate: _disposalDate,
        salePrice: _isSale && _priceController.text.isNotEmpty
            ? Money.fromDouble(
                double.parse(_priceController.text),
                widget.asset.currency,
              )
            : null,
        buyerName: _isSale && _buyerController.text.isNotEmpty
            ? _buyerController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        disposedBy: 'current_user',
      );

      widget.onDispose(params);
      Navigator.pop(context);
    }
  }
}
