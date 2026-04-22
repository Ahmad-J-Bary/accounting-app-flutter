import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../domain/domain.dart';

/// بطاقة ملخص
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PhosphorIcon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// عنصر قائمة الأصول الثابتة
class FixedAssetListTile extends StatelessWidget {
  final FixedAsset asset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDispose;
  final VoidCallback onDepreciate;

  const FixedAssetListTile({
    super.key,
    required this.asset,
    required this.onEdit,
    required this.onDelete,
    required this.onDispose,
    required this.onDepreciate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(asset.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(asset.status),
            color: _getStatusColor(asset.status),
          ),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(asset.code),
            const SizedBox(height: 4),
            Text(
              'القيمة: ${asset.netBookValue.amount.toStringAsFixed(0)} ل.س | '
              'الاهلاك: ${asset.accumulatedDepreciation.amount.toStringAsFixed(0)} ل.س',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(asset.status.displayName),
              backgroundColor: _getStatusColor(asset.status).withOpacity(0.1),
              labelStyle: TextStyle(
                color: _getStatusColor(asset.status),
                fontSize: 12,
              ),
              padding: EdgeInsets.zero,
            ),
            PopupMenuButton<String>(
              icon: PhosphorIcon(PhosphorIcons.dotsThree()),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                  case 'dispose':
                    onDispose();
                    break;
                  case 'depreciate':
                    onDepreciate();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.pencil()),
                      const SizedBox(width: 8),
                      const Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'depreciate',
                  child: Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.trendDown()),
                      const SizedBox(width: 8),
                      const Text('تسجيل اهلاك'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'dispose',
                  child: Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.archive()),
                      const SizedBox(width: 8),
                      const Text('استبعاد/بيع'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.trash(), color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AssetStatus status) {
    switch (status) {
      case AssetStatus.active:
        return Colors.green;
      case AssetStatus.inactive:
        return Colors.grey;
      case AssetStatus.disposed:
        return Colors.red;
      case AssetStatus.sold:
        return Colors.blue;
      case AssetStatus.damaged:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(AssetStatus status) {
    switch (status) {
      case AssetStatus.active:
        return PhosphorIcons.checkCircle();
      case AssetStatus.inactive:
        return PhosphorIcons.pauseCircle();
      case AssetStatus.disposed:
        return PhosphorIcons.archive();
      case AssetStatus.sold:
        return PhosphorIcons.currencyDollar();
      case AssetStatus.damaged:
        return PhosphorIcons.warningCircle();
    }
  }
}

/// عنصر قائمة المستهلكات
class ConsumableListTile extends StatelessWidget {
  final ConsumableItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onIssue;
  final VoidCallback onReceive;

  const ConsumableListTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onIssue,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(item.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(item.status),
            color: _getStatusColor(item.status),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.code),
            const SizedBox(height: 4),
            Text(
              'المخزون: ${item.quantityOnHand.value.toStringAsFixed(0)} ${item.unitOfMeasure.unit} | '
              'القيمة: ${item.totalCost.amount.toStringAsFixed(0)} ل.س',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر صرف سريع
            if (item.quantityOnHand.value > 0)
              IconButton(
                icon: PhosphorIcon(PhosphorIcons.minusCircle()),
                color: Colors.orange,
                tooltip: 'صرف',
                onPressed: onIssue,
              ),
            // زر استلام سريع
            IconButton(
              icon: PhosphorIcon(PhosphorIcons.plusCircle()),
              color: Colors.green,
              tooltip: 'استلام',
              onPressed: onReceive,
            ),
            Chip(
              label: Text(item.status.displayName),
              backgroundColor: _getStatusColor(item.status).withOpacity(0.1),
              labelStyle: TextStyle(
                color: _getStatusColor(item.status),
                fontSize: 12,
              ),
              padding: EdgeInsets.zero,
            ),
            PopupMenuButton<String>(
              icon: PhosphorIcon(PhosphorIcons.dotsThree()),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.pencil()),
                      const SizedBox(width: 8),
                      const Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.trash(), color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ConsumableStatus status) {
    switch (status) {
      case ConsumableStatus.inStock:
        return Colors.green;
      case ConsumableStatus.lowStock:
        return Colors.orange;
      case ConsumableStatus.consumed:
        return Colors.blue;
      case ConsumableStatus.exhausted:
        return Colors.red;
      case ConsumableStatus.damaged:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ConsumableStatus status) {
    switch (status) {
      case ConsumableStatus.inStock:
        return PhosphorIcons.package();
      case ConsumableStatus.lowStock:
        return PhosphorIcons.warning();
      case ConsumableStatus.consumed:
        return PhosphorIcons.checkCircle();
      case ConsumableStatus.exhausted:
        return PhosphorIcons.prohibit();
      case ConsumableStatus.damaged:
        return PhosphorIcons.warningCircle();
    }
  }
}
