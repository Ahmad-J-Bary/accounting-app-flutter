import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:sales/sales.dart';
import 'package:sales/application/use_cases/create_sales_invoice.dart';
import 'package:sales/presentation/state/sales_provider.dart';

class SalesInvoiceForm extends ConsumerStatefulWidget {
  final SalesInvoice? invoice;

  const SalesInvoiceForm({super.key, this.invoice});

  @override
  ConsumerState<SalesInvoiceForm> createState() => _SalesInvoiceFormState();
}

class _SalesInvoiceFormState extends ConsumerState<SalesInvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  String? _customerId;
  final _notesController = TextEditingController();
  final List<SalesInvoiceItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _invoiceNumberController.text = widget.invoice!.invoiceNumber;
      _invoiceDate = widget.invoice!.invoiceDate;
      _dueDate = widget.invoice!.dueDate;
      _customerId = widget.invoice!.customerId.value;
      _notesController.text = widget.invoice!.notes ?? '';
      _items.addAll(widget.invoice!.items ?? []);
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        SalesInvoiceItem(
          id: UniqueId(),
          invoiceId: UniqueId(),
          productId: UniqueId(),
          productName: 'New Item',
          quantity: 1,
          unitPrice: 0,
          lineTotal: 0,
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, SalesInvoiceItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final params = CreateSalesInvoiceParams(
        invoiceNumber: _invoiceNumberController.text,
        customerId: UniqueId.fromUniqueString(_customerId!),
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        items: _items,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final useCase = ref.read(createSalesInvoiceUseCaseProvider);
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
              const SnackBar(content: Text('Invoice created successfully')),
            );
            Navigator.of(context).pop();
            ref.invalidate(salesInvoicesListProvider);
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
    final subtotal = _items.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice));
    final taxAmount = _items.fold<double>(0, (sum, item) => sum + item.taxAmount);
    final totalAmount = subtotal + taxAmount;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: AppInput(
                  label: 'Invoice Number *',
                  controller: _invoiceNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Invoice number is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _invoiceDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => _invoiceDate = date);
                    }
                  },
                  child: AppInput(
                    label: 'Invoice Date',
                    controller: TextEditingController(
                      text: _invoiceDate.toIso8601String().split('T')[0],
                    ),
                    readOnly: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() => _dueDate = date);
              }
            },
            child: AppInput(
              label: 'Due Date',
              controller: TextEditingController(
                text: _dueDate?.toIso8601String().split('T')[0] ?? '',
              ),
              readOnly: true,
            ),
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Customer',
            readOnly: true,
            onTap: () {},
            hintText: 'Select customer',
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              AppButton(
                text: 'Add Item',
                type: AppButtonType.outline,
                onPressed: _addItem,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No items added',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _InvoiceItemCard(
                item: item,
                onRemove: () => _removeItem(index),
                onUpdate: (updatedItem) => _updateItem(index, updatedItem),
              );
            }),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Subtotal: '),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Tax: '),
              Text('\$${taxAmount.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Notes',
            controller: _notesController,
            maxLines: 3,
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
                  text: 'Create Invoice',
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

class _InvoiceItemCard extends StatelessWidget {
  final SalesInvoiceItem item;
  final VoidCallback onRemove;
  final Function(SalesInvoiceItem) onUpdate;

  const _InvoiceItemCard({
    required this.item,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.quantity * item.unitPrice;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: item.quantity.toString()),
                        onChanged: (value) {
                          final qty = double.tryParse(value) ?? item.quantity;
                          onUpdate(item.copyWith(quantity: qty, lineTotal: qty * item.unitPrice));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: item.unitPrice.toString()),
                        onChanged: (value) {
                          final price = double.tryParse(value) ?? item.unitPrice;
                          onUpdate(item.copyWith(unitPrice: price, lineTotal: item.quantity * price));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${lineTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
