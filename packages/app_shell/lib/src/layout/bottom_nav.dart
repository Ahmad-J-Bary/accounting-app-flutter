import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:design_system/design_system.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: PhosphorIcons.squaresFour(),
                label: 'Home',
                path: '/dashboard',
                isSelected: currentPath == '/dashboard',
              ),
              _NavItem(
                icon: PhosphorIcons.users(),
                label: 'Customers',
                path: '/customers',
                isSelected: currentPath == '/customers',
              ),
              _NavItem(
                icon: PhosphorIcons.receipt(),
                label: 'Sales',
                path: '/sales',
                isSelected: currentPath == '/sales',
              ),
              _NavItem(
                icon: PhosphorIcons.gear(),
                label: 'Settings',
                path: '/settings',
                isSelected: currentPath == '/settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isSelected;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(path),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
