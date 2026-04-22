import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:products/products.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(query) ||
          (p.code?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(2)} ر.س';
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(0);
  }

  void _showProductDialog(Product? product) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final codeController = TextEditingController(text: product?.code ?? '');
    final unitPriceController = TextEditingController(text: product?.salePrice.toString() ?? '0');
    final costController = TextEditingController(text: product?.cost.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'تعديل منتج' : 'إضافة منتج جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنتج *',
                  hintText: 'أدخل اسم المنتج',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'كود المنتج *',
                  hintText: 'PRD-XXX',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: unitPriceController,
                      decoration: const InputDecoration(
                        labelText: 'سعر البيع',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: costController,
                      decoration: const InputDecoration(
                        labelText: 'سعر التكلفة',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال اسم المنتج وكود المنتج')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                if (isEditing && product != null) {
                  final updateUseCase = ref.read(updateProductUseCaseProvider);
                  final result = await updateUseCase(UpdateProductParams(
                    id: product.id.value,
                    name: nameController.text,
                    code: codeController.text,
                    salePrice: double.tryParse(unitPriceController.text) ?? product.salePrice,
                    cost: double.tryParse(costController.text) ?? product.cost,
                    isActive: product.isActive,
                  ));
                  result.fold(
                    (failure) => throw Exception(failure.toString()),
                    (_) => ref.invalidate(productsListProvider),
                  );
                } else {
                  final createUseCase = ref.read(createProductUseCaseProvider);
                  final result = await createUseCase(CreateProductParams(
                    code: codeController.text,
                    name: nameController.text,
                    type: ProductType.inventory,
                    purchasePrice: double.tryParse(costController.text) ?? 0,
                    salePrice: double.tryParse(unitPriceController.text) ?? 0,
                    cost: double.tryParse(costController.text) ?? 0,
                  ));
                  result.fold(
                    (failure) => throw Exception(failure.toString()),
                    (_) => ref.invalidate(productsListProvider),
                  );
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'تم تحديث المنتج بنجاح' : 'تم إضافة المنتج بنجاح')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في العملية: $e')),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف المنتج ${product.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final deleteUseCase = ref.read(deleteProductUseCaseProvider);
                final result = await deleteUseCase(product.id.value);
                result.fold(
                  (failure) => throw Exception(failure.toString()),
                  (_) => ref.invalidate(productsListProvider),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المنتج بنجاح')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في الحذف: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: productsAsync.when(
          data: (products) {
            final filteredProducts = _filterProducts(products);
            final activeCount = products.where((p) => p.isActive).length;

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
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
                                  'المنتجات والأصناف',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'إدارة كتالوج المنتجات والمخزون',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Export functionality
                                  },
                                  icon: PhosphorIcon(PhosphorIcons.download()),
                                  label: const Text('تصدير'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _showProductDialog(null),
                                  icon: PhosphorIcon(PhosphorIcons.plus()),
                                  label: const Text('منتج جديد'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _SummaryCard(
                          title: 'إجمالي المنتجات',
                          value: products.length.toString(),
                        ),
                        _SummaryCard(
                          title: 'المنتجات النشطة',
                          value: activeCount.toString(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Table
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Column(
                        children: [
                          // Search bar
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'بحث بالاسم أو الكود...',
                                prefixIcon: PhosphorIcon(PhosphorIcons.magnifyingGlass()),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),

                          // Table
                          DataTable(
                            columns: const [
                              DataColumn(label: Text('الكود')),
                              DataColumn(label: Text('اسم المنتج')),
                              DataColumn(label: Text('التكلفة')),
                              DataColumn(label: Text('السعر')),
                              DataColumn(label: Text('المخزون')),
                              DataColumn(label: Text('الحالة')),
                              DataColumn(label: Text('')),
                            ],
                            rows: filteredProducts.isEmpty
                                ? [
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            'لا توجد منتجات حالياً',
                                            style: TextStyle(color: AppColors.textSecondary),
                                          ),
                                        ),
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                      ],
                                    ),
                                  ]
                                : filteredProducts.map((product) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            product.code ?? '',
                                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataCell(Text(product.name)),
                                        DataCell(Text(_formatCurrency(product.cost))),
                                        DataCell(
                                          Text(
                                            _formatCurrency(product.salePrice),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataCell(
                                          Chip(
                                            label: Text(product.isActive ? 'نشط' : 'غير نشط'),
                                            backgroundColor: product.isActive ? Colors.green[100] : Colors.grey[200],
                                          ),
                                        ),
                                        DataCell.empty,
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: PhosphorIcon(PhosphorIcons.dotsThree()),
                                            onSelected: (value) {
                                              switch (value) {
                                                case 'edit':
                                                  _showProductDialog(product);
                                                  break;
                                                case 'delete':
                                                  _showDeleteConfirmation(product);
                                                  break;
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'view',
                                                child: Row(
                                                  children: [
                                                    PhosphorIcon(PhosphorIcons.eye()),
                                                    SizedBox(width: 8),
                                                    Text('عرض'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    PhosphorIcon(PhosphorIcons.pencil()),
                                                    SizedBox(width: 8),
                                                    Text('تعديل'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    PhosphorIcon(PhosphorIcons.trash()),
                                                    SizedBox(width: 8),
                                                    Text('حذف'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(PhosphorIcons.warningCircle(), size: 48),
                const SizedBox(height: 16),
                Text('خطأ: $error'),
              ],
            ),
          ),
        ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

