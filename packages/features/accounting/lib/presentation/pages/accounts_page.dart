import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:accounting/accounting.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart of Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
            Icon(Icons.account_balance, size: 64, color: AppColors.textDisabled),
            SizedBox(height: 16),
            Text(
              'Accounts Page',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            Text(
              'Chart of accounts coming soon',
              style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}
