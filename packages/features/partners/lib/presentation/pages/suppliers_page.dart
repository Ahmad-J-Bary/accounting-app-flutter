import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partners/partners.dart';
import 'package:design_system/design_system.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Supplier> _filterSuppliers(List<Supplier> suppliers) {
    if (_searchQuery.isEmpty) return suppliers;
    final query = _searchQuery.toLowerCase();
    return suppliers.where((s) {
      return s.name.toLowerCase().contains(query) ||
          (s.phone?.toLowerCase().contains(query) ?? false) ||
          (s.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(2)} ر.س';
  }

  void _showSupplierDialog(Supplier? supplier) {
    final isEditing = supplier != null;
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController = TextEditingController(text: supplier?.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'تعديل بيانات المورد' : 'إضافة مورد جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المورد *',
                  hintText: 'أدخل اسم المورد',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف *',
                  hintText: '05xxxxxxxx',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  hintText: 'example@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  hintText: 'عنوان المورد',
                ),
                maxLines: 2,
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
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال الاسم ورقم الهاتف')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                if (isEditing && supplier != null) {
                  final updateUseCase = ref.read(updateSupplierUseCaseProvider);
                  final result = await updateUseCase(UpdateSupplierParams(
                    id: supplier.id.value,
                    name: nameController.text,
                    phone: phoneController.text,
                    email: emailController.text.isEmpty ? null : emailController.text,
                    address: addressController.text.isEmpty ? null : addressController.text,
                    isActive: supplier.isActive,
                  ));
                  result.fold(
                    (failure) => throw Exception(failure.toString()),
                    (_) => ref.invalidate(suppliersListProvider),
                  );
                } else {
                  final createUseCase = ref.read(createSupplierUseCaseProvider);
                  final result = await createUseCase(CreateSupplierParams(
                    code: 'SUPP-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    phone: phoneController.text,
                    email: emailController.text.isEmpty ? null : emailController.text,
                    address: addressController.text.isEmpty ? null : addressController.text,
                  ));
                  result.fold(
                    (failure) => throw Exception(failure.toString()),
                    (_) => ref.invalidate(suppliersListProvider),
                  );
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'تم تحديث بيانات المورد بنجاح' : 'تم إضافة المورد بنجاح')),
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

  void _showDeleteConfirmation(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المورد'),
        content: Text('هل أنت متأكد من حذف المورد ${supplier.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final deleteUseCase = ref.read(deleteSupplierUseCaseProvider);
                final result = await deleteUseCase(supplier.id.value);
                result.fold(
                  (failure) => throw Exception(failure.toString()),
                  (_) => ref.invalidate(suppliersListProvider),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المورد بنجاح')),
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
    final suppliersAsync = ref.watch(suppliersListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: suppliersAsync.when(
          data: (suppliers) {
            final filteredSuppliers = _filterSuppliers(suppliers);
            final totalBalance = suppliers.fold<double>(0, (sum, s) => sum + s.currentBalance);
            final activeCount = suppliers.where((s) => s.isActive).length;
            final withBalanceCount = suppliers.where((s) => s.currentBalance > 0).length;

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
                                  'الموردون',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'إدارة قاعدة بيانات الموردين وأرصدتهم',
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
                                  icon: PhosphorIcon(PhosphorIcons.arrowsClockwise()),
                                  label: const Text('تحديث'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _showSupplierDialog(null),
                                  icon: PhosphorIcon(PhosphorIcons.plus()),
                                  label: const Text('مورد جديد'),
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
                          title: 'إجمالي الموردين',
                          value: suppliers.length.toString(),
                        ),
                        _SummaryCard(
                          title: 'الموردون النشطون',
                          value: activeCount.toString(),
                          valueColor: Colors.green,
                        ),
                        _SummaryCard(
                          title: 'إجمالي الذمم الدائنة',
                          value: _formatCurrency(totalBalance),
                          valueColor: Colors.red,
                        ),
                        _SummaryCard(
                          title: 'موردون بأرصدة',
                          value: withBalanceCount.toString(),
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
                                hintText: 'بحث بالاسم أو الهاتف...',
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
                              DataColumn(label: Text('اسم المورد')),
                              DataColumn(label: Text('الهاتف')),
                              DataColumn(label: Text('البريد')),
                              DataColumn(label: Text('العنوان')),
                              DataColumn(label: Text('الرصيد')),
                              DataColumn(label: Text('الحالة')),
                              DataColumn(label: Text('')),
                            ],
                            rows: filteredSuppliers.isEmpty
                                ? [
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            'لا يوجد موردون — أضف موردًا جديدًا',
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
                                : filteredSuppliers.map((supplier) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(supplier.name)),
                                        DataCell(Text(supplier.phone ?? '-')),
                                        DataCell(Text(supplier.email ?? '-', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                        DataCell(Text(supplier.address ?? '-', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                        DataCell(
                                          Text(
                                            _formatCurrency(supplier.currentBalance),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataCell(
                                          Chip(
                                            label: Text(supplier.isActive ? 'نشط' : 'غير نشط'),
                                            backgroundColor: supplier.isActive ? Colors.green[100] : Colors.grey[200],
                                          ),
                                        ),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: PhosphorIcon(PhosphorIcons.dotsThree()),
                                            onSelected: (value) {
                                              switch (value) {
                                                case 'edit':
                                                  _showSupplierDialog(supplier);
                                                  break;
                                                case 'delete':
                                                  _showDeleteConfirmation(supplier);
                                                  break;
                                                case 'print':
                                                  // TODO: Implement print statement
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
                                              PopupMenuItem(
                                                value: 'print',
                                                child: Row(
                                                  children: [
                                                    PhosphorIcon(PhosphorIcons.printer()),
                                                    SizedBox(width: 8),
                                                    Text('طباعة'),
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

