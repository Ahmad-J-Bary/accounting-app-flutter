import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/inventory.dart';

class WarehousesPage extends ConsumerWidget {
  const WarehousesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehousesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWarehouseDialog(context, ref),
          ),
        ],
      ),
      body: warehousesAsync.when(
        data: (warehouses) => warehouses.isEmpty
            ? const Center(child: Text('No warehouses found'))
            : ListView.builder(
                itemCount: warehouses.length,
                itemBuilder: (context, index) {
                  final warehouse = warehouses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(warehouse.name[0]),
                      ),
                      title: Text(warehouse.name),
                      subtitle: Text('${warehouse.code} - ${warehouse.address ?? "No address"}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            warehouse.isActive ? Icons.check_circle : Icons.cancel,
                            color: warehouse.isActive ? Colors.green : Colors.red,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditWarehouseDialog(context, ref, warehouse),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(context, ref, warehouse),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showAddWarehouseDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final managerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Warehouse'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: managerController,
                decoration: const InputDecoration(labelText: 'Manager'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call create use case
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditWarehouseDialog(BuildContext context, WidgetRef ref, Warehouse warehouse) {
    // TODO: Implement edit dialog
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Warehouse warehouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Warehouse'),
        content: Text('Are you sure you want to delete ${warehouse.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
