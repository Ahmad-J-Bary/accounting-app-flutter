import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partners/partners.dart';
import 'package:design_system/design_system.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Customer? _selectedCustomer;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> _filterCustomers(List<Customer> customers) {
    if (_searchQuery.isEmpty) return customers;
    final query = _searchQuery.toLowerCase();
    return customers.where((c) {
      return c.name.toLowerCase().contains(query) ||
          (c.phone?.toLowerCase().contains(query) ?? false) ||
          (c.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(2)} ر.س';
  }

  void _showCustomerDialog(Customer? customer) {
    final isEditing = customer != null;
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final addressController = TextEditingController(text: customer?.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'تعديل بيانات العميل' : 'إضافة عميل جديد'),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم العميل *',
                    hintText: 'أدخل اسم العميل',
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
                    hintText: 'عنوان العميل',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
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
                if (isEditing && customer != null) {
                  final updateUseCase = ref.read(updateCustomerUseCaseProvider);
                  final result = await updateUseCase(UpdateCustomerParams(
                    id: customer.id.value,
                    name: nameController.text,
                    phone: phoneController.text,
                    email: emailController.text.isEmpty ? null : emailController.text,
                    address: addressController.text.isEmpty ? null : addressController.text,
                    isActive: customer.isActive,
                  ));
                  result.fold(
                    (failure) => throw Exception(failure.toString()),
                    (_) => ref.invalidate(customersListProvider),
                  );
                } else {
                  final createUseCase = ref.read(createCustomerUseCaseProvider);
                  final result = await createUseCase(CreateCustomerParams(
                    code: 'CUST-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    phone: phoneController.text,
                    email: emailController.text.isEmpty ? null : emailController.text,
                    address: addressController.text.isEmpty ? null : addressController.text,
                  ));
                  result.fold(
                    (failure) => throw Exception(failure.toString()),
                    (_) => ref.invalidate(customersListProvider),
                  );
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'تم تحديث بيانات العميل بنجاح' : 'تم إضافة العميل بنجاح')),
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

  void _showDeleteConfirmation(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العميل'),
        content: Text('هل أنت متأكد من حذف العميل ${customer.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final deleteUseCase = ref.read(deleteCustomerUseCaseProvider);
                final result = await deleteUseCase(customer.id.value);
                result.fold(
                  (failure) => throw Exception(failure.toString()),
                  (_) => ref.invalidate(customersListProvider),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف العميل بنجاح')),
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
    final customersAsync = ref.watch(customersListProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: customersAsync.when(
          data: (customers) {
            final filteredCustomers = _filterCustomers(customers);
            final totalBalance = customers.fold<double>(0, (sum, c) => sum + c.currentBalance);
            final activeCount = customers.where((c) => c.isActive).length;
            final zeroBalanceCount = customers.where((c) => c.currentBalance == 0).length;

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
                                  'العملاء',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'إدارة قاعدة بيانات العملاء والأرصدة',
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
                                  onPressed: () => _showCustomerDialog(null),
                                  icon: PhosphorIcon(PhosphorIcons.plus()),
                                  label: const Text('عميل جديد'),
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
                          title: 'إجمالي العملاء',
                          value: customers.length.toString(),
                        ),
                        _SummaryCard(
                          title: 'العملاء النشطون',
                          value: activeCount.toString(),
                          valueColor: Colors.green,
                        ),
                        _SummaryCard(
                          title: 'إجمالي الذمم',
                          value: _formatCurrency(totalBalance),
                          valueColor: AppColors.primary,
                        ),
                        _SummaryCard(
                          title: 'عملاء بأرصدة صفرية',
                          value: zeroBalanceCount.toString(),
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
                                hintText: 'بحث بالاسم، الكود، الهاتف...',
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
                              DataColumn(label: Text('الاسم')),
                              DataColumn(label: Text('الهاتف')),
                              DataColumn(label: Text('العنوان')),
                              DataColumn(label: Text('الرصيد')),
                              DataColumn(label: Text('الحالة')),
                              DataColumn(label: Text('')),
                            ],
                            rows: filteredCustomers.isEmpty
                                ? [
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            'لا يوجد عملاء حالياً',
                                            style: TextStyle(color: AppColors.textSecondary),
                                          ),
                                        ),
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                      ],
                                    ),
                                  ]
                                : filteredCustomers.map((customer) {
                                    return DataRow(
                                      onSelectChanged: (selected) {
                                        if (selected ?? false) {
                                          setState(() {
                                            _selectedCustomer = customer;
                                          });
                                          _showCustomerDetailSheet(customer);
                                        }
                                      },
                                      cells: [
                                        DataCell(Text(customer.name)),
                                        DataCell(Text(customer.phone ?? '-')),
                                        DataCell(Text(customer.address ?? '-')),
                                        DataCell(
                                          Text(
                                            _formatCurrency(customer.currentBalance),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataCell(
                                          Chip(
                                            label: Text(customer.isActive ? 'نشط' : 'غير نشط'),
                                            backgroundColor: customer.isActive ? Colors.green[100] : Colors.grey[200],
                                          ),
                                        ),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: PhosphorIcon(PhosphorIcons.dotsThree()),
                                            onSelected: (value) {
                                              switch (value) {
                                                case 'view':
                                                  setState(() {
                                                    _selectedCustomer = customer;
                                                  });
                                                  _showCustomerDetailSheet(customer);
                                                  break;
                                                case 'edit':
                                                  _showCustomerDialog(customer);
                                                  break;
                                                case 'delete':
                                                  _showDeleteConfirmation(customer);
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
                                                    Text('عرض الملف'),
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
      ),
    );
  }

  void _showCustomerDetailSheet(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ملف العميل - ${customer.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: PhosphorIcon(PhosphorIcons.x()),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Summary
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الرصيد الحالي',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatCurrency(customer.currentBalance),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحالة',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(customer.isActive ? 'نشط' : 'غير نشط'),
                              backgroundColor: customer.isActive ? Colors.green[100] : Colors.grey[200],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.phone()),
                      const SizedBox(width: 8),
                      Text(customer.phone ?? 'لا يوجد هاتف'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.envelope()),
                      const SizedBox(width: 8),
                      Text(customer.email ?? 'لا يوجد بريد'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.mapPin()),
                      const SizedBox(width: 8),
                      Text(customer.address ?? 'لا يوجد عنوان'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tabs
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'الفواتير'),
                        Tab(text: 'المقبوضات'),
                        Tab(text: 'كشف الحساب'),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      child: TabBarView(
                        children: [
                          const Center(child: Text('لا تنطبق البيانات الوهمية هنا — سيتم ربطها بالمبيعات قريباً')),
                          const Center(child: Text('سجل الدفعات فارغ')),
                          const Center(child: Text('سجل العمليات فارغ')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
