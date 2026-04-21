import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_shell/src/layout/sidebar.dart';
import 'package:app_shell/src/layout/bottom_nav.dart';
import 'package:design_system/design_system.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (isDesktop) const Sidebar(),
          Expanded(
            child: Column(
              children: [
                if (!isDesktop) const BottomNav(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
