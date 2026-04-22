import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../domain/domain.dart';
import '../state/consumables_notifier.dart';
import '../state/consumables_state.dart';
import '../widgets/asset_widgets.dart';

/// صفحة إدارة المستهلكات
class ConsumablesPage extends ConsumerStatefulWidget {
  const ConsumablesPage({super.key});

  @override
  ConsumerState<ConsumablesPage> createState() => _ConsumablesPageState();
}

class _ConsumablesPageState extends ConsumerState<ConsumablesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(consumablesNotifierProvider.notifier).loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consumablesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state is ConsumableError
          ? _ErrorView(message: (state as ConsumableError).message)
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _Header(
                    searchController: _searchController,
                    onSearch: (value) {
                      ref.read(consumablesNotifierProvider.notifier).searchItems(value);
                    },
                    onRefresh: () {
                      ref.read(consumablesNotifierProvider.notifier).refresh();
                    },
                  ),
                ),

                // Summary Cards
                if (state is ConsumablesLoaded && state.summary != null)
                  SliverToBoxAdapter(
                    child: _SummaryCards(summary: state.summary!),
                  ),

                // Filter Chips
                SliverToBoxAdapter(
                  child: _FilterChips(
                    selectedStatus: state is ConsumablesLoaded ? state.filterStatus : null,
                    lowStockOnly: state is ConsumablesLoaded ? state.lowStockOnly : false,
                    onFilterChanged: (status) {
                      ref.read(consumablesNotifierProvider.notifier).filterByStatus(status);
                    },
                    onLowStockChanged: (show) {
                      ref.read(consumablesNotifierProvider.notifier).showLowStockOnly(show);
                    },
                  ),
                ),

                // Items List
                state is ConsumablesLoaded
                    ? _ItemsList(
                        items: state.items,
                        onEdit: (item) => _showItemDialog(item),
                        onDelete: (item) => _confirmDelete(item),
                        onIssue: (item) => _showIssueDialog(item),
                        onReceive: (item) => _showReceiveDialog(item),
                      )
                    : const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(null),
        backgroundColor: AppColors.primary,
        icon: PhosphorIcon(PhosphorIcons.plus()),
        label: const Text('مستهلك جديد'),
      ),
    );
  }

  void _showItemDialog(ConsumableItem? item) {
    showDialog(
      context: context,
      builder: (context) => ConsumableDialog(
        item: item,
        onSave: (params) {
          if (item == null) {
            ref.read(consumablesNotifierProvider.notifier).createItem(params);
          } else {
            // TODO: Implement update
          }
        },
      ),
    );
  }

  void _confirmDelete(ConsumableItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستهلك'),
        content: Text('هل أنت متأكد من حذف ${item.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(consumablesNotifierProvider.notifier).deleteItem(
                item.id,
                'current_user',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showIssueDialog(ConsumableItem item) {
    showDialog(
      context: context,
      builder: (context) => IssueConsumableDialog(
        item: item,
        onIssue: (params) {
          ref.read(consumablesNotifierProvider.notifier).issueItem(params);
        },
      ),
    );
  }

  void _showReceiveDialog(ConsumableItem item) {
    showDialog(
      context: context,
      builder: (context) => ReceiveConsumableDialog(
        item: item,
        onReceive: (params) {
          ref.read(consumablesNotifierProvider.notifier).receiveItem(params);
        },
      ),
    );
  }
}

/// Header مع البحث
class _Header extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;

  const _Header({
    required this.searchController,
    required this.onSearch,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المستهلكات والمخزون',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إدارة مواد التشغيل والصرف والاستلام',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onRefresh,
                    icon: PhosphorIcon(PhosphorIcons.arrowsClockwise()),
                    label: const Text('تحديث'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'بحث بالاسم أو الكود...',
              prefixIcon: PhosphorIcon(PhosphorIcons.magnifyingGlass()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onSearch,
          ),
        ],
      ),
    );
  }
}

/// بطاقات الملخص
class _SummaryCards extends StatelessWidget {
  final ConsumablesSummary summary;

  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          SummaryCard(
            title: 'إجمالي الأصناف',
            value: summary.totalCount.toString(),
            icon: PhosphorIcons.package(),
            color: AppColors.primary,
          ),
          SummaryCard(
            title: 'المتوفر',
            value: summary.inStockCount.toString(),
            icon: PhosphorIcons.checkCircle(),
            color: Colors.green,
          ),
          SummaryCard(
            title: 'المخزون المنخفض',
            value: summary.lowStockCount.toString(),
            icon: PhosphorIcons.warning(),
            color: Colors.orange,
          ),
          SummaryCard(
            title: 'القيمة الإجمالية',
            value: '${summary.totalValue.amount.toStringAsFixed(0)} ل.س',
            icon: PhosphorIcons.currencyDollar(),
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

/// فلاتر الحالة
class _FilterChips extends StatelessWidget {
  final ConsumableStatus? selectedStatus;
  final bool lowStockOnly;
  final ValueChanged<ConsumableStatus?> onFilterChanged;
  final ValueChanged<bool> onLowStockChanged;

  const _FilterChips({
    this.selectedStatus,
    this.lowStockOnly = false,
    required this.onFilterChanged,
    required this.onLowStockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('الكل'),
            selected: selectedStatus == null && !lowStockOnly,
            onSelected: (_) {
              onFilterChanged(null);
              onLowStockChanged(false);
            },
          ),
          FilterChip(
            label: const Text('منخفض'),
            selected: lowStockOnly,
            onSelected: (selected) => onLowStockChanged(selected),
            selectedColor: Colors.orange.shade100,
          ),
          ...ConsumableStatus.values.map((status) {
            return FilterChip(
              label: Text(status.displayName),
              selected: selectedStatus == status,
              onSelected: (_) => onFilterChanged(status),
            );
          }),
        ],
      ),
    );
  }
}

/// قائمة المستهلكات
class _ItemsList extends StatelessWidget {
  final List<ConsumableItem> items;
  final Function(ConsumableItem) onEdit;
  final Function(ConsumableItem) onDelete;
  final Function(ConsumableItem) onIssue;
  final Function(ConsumableItem) onReceive;

  const _ItemsList({
    required this.items,
    required this.onEdit,
    required this.onDelete,
    required this.onIssue,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('لا توجد مستهلكات'),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return ConsumableListTile(
              item: item,
              onEdit: () => onEdit(item),
              onDelete: () => onDelete(item),
              onIssue: () => onIssue(item),
              onReceive: () => onReceive(item),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

/// عرض الخطأ
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(PhosphorIcons.warningCircle(), size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
