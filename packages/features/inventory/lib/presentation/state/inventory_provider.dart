import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform/local_db/local_db.dart';
import 'package:inventory/inventory.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return WarehouseRepositoryImpl(database);
});

final stockMovementRepositoryProvider = Provider<StockMovementRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return StockMovementRepositoryImpl(database);
});

final createWarehouseUseCaseProvider = Provider<CreateWarehouseUseCase>((ref) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return CreateWarehouseUseCase(repository);
});

final warehousesListProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (warehouses) => warehouses,
  );
});

final stockMovementsListProvider = FutureProvider<List<StockMovement>>((ref) async {
  final repository = ref.watch(stockMovementRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movements) => movements,
  );
});
