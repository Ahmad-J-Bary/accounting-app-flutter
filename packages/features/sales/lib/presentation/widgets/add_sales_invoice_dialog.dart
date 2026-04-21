import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:sales/presentation/widgets/sales_invoice_form.dart';

class AddSalesInvoiceDialog extends StatelessWidget {
  const AddSalesInvoiceDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AddSalesInvoiceDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Create Sales Invoice',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Expanded(
                child: SingleChildScrollView(
                  child: SalesInvoiceForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
