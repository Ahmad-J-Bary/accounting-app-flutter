import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:design_system/design_system.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 280,
      color: AppColors.surface,
      child: Column(
        children: [
          const _SidebarHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(
                  icon: PhosphorIcons.squaresFour(),
                  label: 'Dashboard',
                  path: '/dashboard',
                  isSelected: currentPath == '/dashboard',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.users(),
                  label: 'Customers',
                  path: '/customers',
                  isSelected: currentPath == '/customers',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.truck(),
                  label: 'Suppliers',
                  path: '/suppliers',
                  isSelected: currentPath == '/suppliers',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.package(),
                  label: 'Products',
                  path: '/products',
                  isSelected: currentPath == '/products',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.warehouse(),
                  label: 'Inventory',
                  path: '/inventory',
                  isSelected: currentPath == '/inventory',
                ),
                const Divider(height: 32),
                _SidebarItem(
                  icon: PhosphorIcons.receipt(),
                  label: 'Sales',
                  path: '/sales',
                  isSelected: currentPath == '/sales',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.shoppingCart(),
                  label: 'Purchases',
                  path: '/purchases',
                  isSelected: currentPath == '/purchases',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.currencyDollar(),
                  label: 'Payments',
                  path: '/payments',
                  isSelected: currentPath == '/payments',
                ),
                const Divider(height: 32),
                _SidebarItem(
                  icon: PhosphorIcons.chartBar(),
                  label: 'Accounting',
                  path: '/accounting',
                  isSelected: currentPath == '/accounting',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.bookOpen(),
                  label: 'Journal',
                  path: '/journal',
                  isSelected: currentPath == '/journal',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.chartPie(),
                  label: 'Reports',
                  path: '/reports',
                  isSelected: currentPath == '/reports',
                ),
                const Divider(height: 32),
                _SidebarItem(
                  icon: PhosphorIcons.gear(),
                  label: 'Settings',
                  path: '/settings',
                  isSelected: currentPath == '/settings',
                ),
                _SidebarItem(
                  icon: PhosphorIcons.user(),
                  label: 'Users',
                  path: '/users',
                  isSelected: currentPath == '/users',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PhosphorIcon(
              PhosphorIcons.wallet(),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Accounting',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isSelected;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(path),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          border: isSelected
              ? const Border(
                  right: BorderSide(color: AppColors.primary, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
