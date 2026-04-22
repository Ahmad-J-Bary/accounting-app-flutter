import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../domain/domain.dart';
import '../state/fixed_assets_notifier.dart';
import '../state/fixed_assets_state.dart';
import '../widgets/asset_widgets.dart';

/// صفحة إدارة الأصول الثابتة
class FixedAssetsPage extends ConsumerStatefulWidget {
  const FixedAssetsPage({super.key});

  @override
  ConsumerState<FixedAssetsPage> createState() => _FixedAssetsPageState();
}

class _FixedAssetsPageState extends ConsumerState<FixedAssetsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الصفحة
    Future.microtask(() {
      ref.read(fixedAssetsNotifierProvider.notifier).loadAssets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fixedAssetsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state is FixedAssetError
          ? _ErrorView(message: (state as FixedAssetError).message)
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _Header(
                    searchController: _searchController,
                    onSearch: (value) {
                      ref.read(fixedAssetsNotifierProvider.notifier).searchAssets(value);
                    },
                    onRefresh: () {
                      ref.read(fixedAssetsNotifierProvider.notifier).refresh();
                    },
                  ),
                ),

                // Summary Cards
                if (state is FixedAssetsLoaded && state.summary != null)
                  SliverToBoxAdapter(
                    child: _SummaryCards(summary: state.summary!),
                  ),

                // Filter Chips
                SliverToBoxAdapter(
                  child: _FilterChips(
                    selectedStatus: state is FixedAssetsLoaded ? state.filterStatus : null,
                    onFilterChanged: (status) {
                      ref.read(fixedAssetsNotifierProvider.notifier).filterByStatus(status);
                    },
                  ),
                ),

                // Assets List
                state is FixedAssetsLoaded
                    ? _AssetsList(
                        assets: state.assets,
                        onEdit: (asset) => _showAssetDialog(asset),
                        onDelete: (asset) => _confirmDelete(asset),
                        onDispose: (asset) => _showDisposeDialog(asset),
                        onDepreciate: (asset) => _postDepreciation(asset),
                      )
                    : const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssetDialog(null),
        backgroundColor: AppColors.primary,
        icon: PhosphorIcon(PhosphorIcons.plus()),
        label: const Text('أصل جديد'),
      ),
    );
  }

  void _showAssetDialog(FixedAsset? asset) {
    showDialog(
      context: context,
      builder: (context) => FixedAssetDialog(
        asset: asset,
        onSave: (params) {
          if (asset == null) {
            ref.read(fixedAssetsNotifierProvider.notifier).createAsset(params);
          } else {
            // TODO: Implement update
          }
        },
      ),
    );
  }

  void _confirmDelete(FixedAsset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الأصل'),
        content: Text('هل أنت متأكد من حذف ${asset.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(fixedAssetsNotifierProvider.notifier).deleteAsset(
                asset.id,
                'current_user', // TODO: Get actual user
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDisposeDialog(FixedAsset asset) {
    showDialog(
      context: context,
      builder: (context) => DisposeAssetDialog(
        asset: asset,
        onDispose: (params) {
          ref.read(fixedAssetsNotifierProvider.notifier).disposeAsset(params);
        },
      ),
    );
  }

  void _postDepreciation(FixedAsset asset) {
    // TODO: Show confirmation and date picker
    ref.read(fixedAssetsNotifierProvider.notifier).postDepreciation(
      asset.id,
      DateTime.now(),
      'current_user',
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
                    'الموجودات الثابتة',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إدارة الأصول والمعدات والاهلاك',
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
  final FixedAssetsSummary summary;

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
            title: 'إجمالي الأصول',
            value: summary.totalCount.toString(),
            icon: PhosphorIcons.buildings(),
            color: AppColors.primary,
          ),
          SummaryCard(
            title: 'الأصول النشطة',
            value: summary.activeCount.toString(),
            icon: PhosphorIcons.checkCircle(),
            color: Colors.green,
          ),
          SummaryCard(
            title: 'القيمة الدفترية',
            value: '${summary.totalNetBookValue.amount.toStringAsFixed(0)} ل.س',
            icon: PhosphorIcons.currencyDollar(),
            color: AppColors.accent,
          ),
          SummaryCard(
            title: 'مجمع الاهلاك',
            value: '${summary.totalAccumulatedDepreciation.amount.toStringAsFixed(0)} ل.س',
            icon: PhosphorIcons.trendDown(),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

/// فلاتر الحالة
class _FilterChips extends StatelessWidget {
  final AssetStatus? selectedStatus;
  final ValueChanged<AssetStatus?> onFilterChanged;

  const _FilterChips({
    this.selectedStatus,
    required this.onFilterChanged,
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
            selected: selectedStatus == null,
            onSelected: (_) => onFilterChanged(null),
          ),
          ...AssetStatus.values.map((status) {
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

/// قائمة الأصول
class _AssetsList extends StatelessWidget {
  final List<FixedAsset> assets;
  final Function(FixedAsset) onEdit;
  final Function(FixedAsset) onDelete;
  final Function(FixedAsset) onDispose;
  final Function(FixedAsset) onDepreciate;

  const _AssetsList({
    required this.assets,
    required this.onEdit,
    required this.onDelete,
    required this.onDispose,
    required this.onDepreciate,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('لا توجد أصول ثابتة'),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final asset = assets[index];
            return FixedAssetListTile(
              asset: asset,
              onEdit: () => onEdit(asset),
              onDelete: () => onDelete(asset),
              onDispose: () => onDispose(asset),
              onDepreciate: () => onDepreciate(asset),
            );
          },
          childCount: assets.length,
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
