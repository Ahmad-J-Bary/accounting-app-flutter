import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:sales/sales.dart';
import 'package:sales/presentation/widgets/add_sales_invoice_dialog.dart';
import 'package:sales/presentation/state/sales_provider.dart';

class SalesInvoicesPage extends ConsumerStatefulWidget {
  const SalesInvoicesPage({super.key});

  @override
  ConsumerState<SalesInvoicesPage> createState() => _SalesInvoicesPageState();
}

class _SalesInvoicesPageState extends ConsumerState<SalesInvoicesPage> {
  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(salesInvoicesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AddSalesInvoiceDialog.show(context),
          ),
        ],
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: AppColors.textDisabled),
                  SizedBox(height: 16),
                  Text(
                    'No invoices yet',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first sales invoice to get started',
                    style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getStatusColor(invoice.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: _getStatusColor(invoice.status),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invoiceNumber,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            invoice.invoiceDate.toIso8601String().split('T')[0],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        AppBadge(
                          text: invoice.status.name,
                          type: _getBadgeType(invoice.status),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.partiallyPaid:
        return AppColors.warning;
      case InvoiceStatus.draft:
        return AppColors.textSecondary;
      case InvoiceStatus.posted:
        return AppColors.info;
      case InvoiceStatus.cancelled:
        return AppColors.error;
    }
  }

  AppBadgeType _getBadgeType(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppBadgeType.success;
      case InvoiceStatus.partiallyPaid:
        return AppBadgeType.warning;
      case InvoiceStatus.draft:
        return AppBadgeType.neutral;
      case InvoiceStatus.posted:
        return AppBadgeType.info;
      case InvoiceStatus.cancelled:
        return AppBadgeType.error;
    }
  }
}
