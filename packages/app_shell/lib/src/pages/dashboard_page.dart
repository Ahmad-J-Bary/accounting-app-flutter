import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:design_system/design_system.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'dashboard'.tr(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    title: 'customers'.tr(),
                    value: '156',
                    icon: PhosphorIcons.users,
                    color: AppColors.primary,
                    change: '+12%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _KpiCard(
                    title: 'sales'.tr(),
                    value: '\$45,230',
                    icon: PhosphorIcons.chartLineUp,
                    color: AppColors.success,
                    change: '+23%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _KpiCard(
                    title: 'purchases'.tr(),
                    value: '\$28,450',
                    icon: PhosphorIcons.shoppingCart,
                    color: AppColors.warning,
                    change: '+8%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _KpiCard(
                    title: 'inventory'.tr(),
                    value: '1,234',
                    icon: PhosphorIcons.package,
                    color: AppColors.info,
                    change: '+5%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppCard(
                    title: 'Recent Sales',
                    trailing: TextButton(
                      onPressed: () {},
                      child: Text('View All'.tr()),
                    ),
                    child: Column(
                      children: [
                        _RecentSaleItem(
                          invoice: 'INV-001',
                          customer: 'Ahmed Ali',
                          amount: '\$1,250',
                          date: '2024-01-15',
                          status: InvoiceStatus.paid,
                        ),
                        _RecentSaleItem(
                          invoice: 'INV-002',
                          customer: 'Sara Mohammed',
                          amount: '\$3,450',
                          date: '2024-01-14',
                          status: InvoiceStatus.partiallyPaid,
                        ),
                        _RecentSaleItem(
                          invoice: 'INV-003',
                          customer: 'Omar Hassan',
                          amount: '\$890',
                          date: '2024-01-13',
                          status: InvoiceStatus.paid,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppCard(
                    title: 'Quick Actions',
                    child: Column(
                      children: [
                        _QuickActionButton(
                          icon: PhosphorIcons.plus,
                          label: 'New Sale',
                          onTap: () {},
                        ),
                        _QuickActionButton(
                          icon: PhosphorIcons.userPlus,
                          label: 'Add Customer',
                          onTap: () {},
                        ),
                        _QuickActionButton(
                          icon: PhosphorIcons.package,
                          label: 'Add Product',
                          onTap: () {},
                        ),
                        _QuickActionButton(
                          icon: PhosphorIcons.receipt,
                          label: 'New Invoice',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentSaleItem extends StatelessWidget {
  final String invoice;
  final String customer;
  final String amount;
  final String date;
  final InvoiceStatus status;

  const _RecentSaleItem({
    required this.invoice,
    required this.customer,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  invoice,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          AppBadge(
            text: status.name,
            type: status == InvoiceStatus.paid
                ? AppBadgeType.success
                : AppBadgeType.warning,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(label),
            const Spacer(),
            Icon(
              PhosphorIcons.caretRight,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

enum InvoiceStatus {
  paid,
  partiallyPaid,
  draft,
  cancelled,
}
