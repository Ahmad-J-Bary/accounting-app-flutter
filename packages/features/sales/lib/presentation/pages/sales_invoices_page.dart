import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:sales/sales.dart';

class SalesInvoicesPage extends ConsumerStatefulWidget {
  const SalesInvoicesPage({super.key});

  @override
  ConsumerState<SalesInvoicesPage> createState() => _SalesInvoicesPageState();
}

class _SalesInvoicesPageState extends ConsumerState<SalesInvoicesPage> {
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppColors.textDisabled),
            SizedBox(height: 16),
            Text(
              'Sales Invoices Page',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            Text(
              'Sales invoice management coming soon',
              style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}
