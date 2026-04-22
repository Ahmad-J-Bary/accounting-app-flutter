import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_shell/src/layout/app_shell.dart';
import 'package:partners/partners.dart';
import 'package:products/products.dart';
import 'package:inventory/inventory.dart';

enum AppRoute {
  home,
  dashboard,
  customers,
  suppliers,
  products,
  inventory,
  sales,
  purchases,
  payments,
  accounting,
  journal,
  reports,
  settings,
  users,
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppShell(child: DashboardPage()),
      ),
      GoRoute(
        path: '/dashboard',
        name: AppRoute.dashboard.name,
        builder: (context, state) => const AppShell(child: DashboardPage()),
      ),
      GoRoute(
        path: '/customers',
        name: AppRoute.customers.name,
        builder: (context, state) => const AppShell(child: CustomersPage()),
      ),
      GoRoute(
        path: '/suppliers',
        name: AppRoute.suppliers.name,
        builder: (context, state) => const AppShell(child: SuppliersPage()),
      ),
      GoRoute(
        path: '/products',
        name: AppRoute.products.name,
        builder: (context, state) => const AppShell(child: ProductsPage()),
      ),
      GoRoute(
        path: '/inventory',
        name: AppRoute.inventory.name,
        builder: (context, state) => const AppShell(child: WarehousesPage()),
      ),
      GoRoute(
        path: '/sales',
        name: AppRoute.sales.name,
        builder: (context, state) => const AppShell(child: SalesPage()),
      ),
      GoRoute(
        path: '/purchases',
        name: AppRoute.purchases.name,
        builder: (context, state) => const AppShell(child: PurchasesPage()),
      ),
      GoRoute(
        path: '/payments',
        name: AppRoute.payments.name,
        builder: (context, state) => const AppShell(child: PaymentsPage()),
      ),
      GoRoute(
        path: '/accounting',
        name: AppRoute.accounting.name,
        builder: (context, state) => const AppShell(child: AccountingPage()),
      ),
      GoRoute(
        path: '/journal',
        name: AppRoute.journal.name,
        builder: (context, state) => const AppShell(child: JournalPage()),
      ),
      GoRoute(
        path: '/reports',
        name: AppRoute.reports.name,
        builder: (context, state) => const AppShell(child: ReportsPage()),
      ),
      GoRoute(
        path: '/settings',
        name: AppRoute.settings.name,
        builder: (context, state) => const AppShell(child: SettingsPage()),
      ),
      GoRoute(
        path: '/users',
        name: AppRoute.users.name,
        builder: (context, state) => const AppShell(child: UsersPage()),
      ),
    ],
  );
}


// Placeholder pages for features not yet implemented
class SalesPage extends StatelessWidget {
  const SalesPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Sales'));
}

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Purchases'));
}

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Payments'));
}

class AccountingPage extends StatelessWidget {
  const AccountingPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Accounting'));
}

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Journal'));
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Reports'));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Settings'));
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Dashboard'));
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Users'));
}
