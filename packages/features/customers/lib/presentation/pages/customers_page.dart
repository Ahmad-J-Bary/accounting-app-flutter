import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:customers/customers.dart';
import 'package:customers/presentation/widgets/add_customer_dialog.dart';
import 'package:customers/presentation/state/customers_provider.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AddCustomerDialog.show(context),
          ),
        ],
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.textDisabled),
                  SizedBox(height: 16),
                  Text(
                    'No customers yet',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first customer to get started',
                    style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        customer.name[0].toUpperCase(),
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            customer.code,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (customer.phone != null)
                      Text(
                        customer.phone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
