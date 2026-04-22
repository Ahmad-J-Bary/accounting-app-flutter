import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/application.dart';
import '../../../domain/domain.dart';
import 'consumables_state.dart';

/// مدير حالة المستهلكات (StateNotifier)
class ConsumablesNotifier extends StateNotifier<ConsumablesState> {
  final GetConsumablesUseCase _getItemsUseCase;
  final GetConsumablesSummaryUseCase _getSummaryUseCase;
  final CreateConsumableUseCase _createItemUseCase;
  final UpdateConsumableUseCase _updateItemUseCase;
  final DeleteConsumableUseCase _deleteItemUseCase;
  final IssueConsumableUseCase _issueItemUseCase;
  final ReceiveConsumableUseCase _receiveItemUseCase;
  final AdjustConsumableStockUseCase _adjustStockUseCase;

  ConsumablesNotifier({
    required GetConsumablesUseCase getItemsUseCase,
    required GetConsumablesSummaryUseCase getSummaryUseCase,
    required CreateConsumableUseCase createItemUseCase,
    required UpdateConsumableUseCase updateItemUseCase,
    required DeleteConsumableUseCase deleteItemUseCase,
    required IssueConsumableUseCase issueItemUseCase,
    required ReceiveConsumableUseCase receiveItemUseCase,
    required AdjustConsumableStockUseCase adjustStockUseCase,
  })  : _getItemsUseCase = getItemsUseCase,
        _getSummaryUseCase = getSummaryUseCase,
        _createItemUseCase = createItemUseCase,
        _updateItemUseCase = updateItemUseCase,
        _deleteItemUseCase = deleteItemUseCase,
        _issueItemUseCase = issueItemUseCase,
        _receiveItemUseCase = receiveItemUseCase,
        _adjustStockUseCase = adjustStockUseCase,
        super(const ConsumablesInitial());

  /// تحميل قائمة المستهلكات
  Future<void> loadItems({
    ConsumableStatus? status,
    bool? lowStockOnly,
    String? searchQuery,
  }) async {
    state = const ConsumablesLoading();

    final params = GetConsumablesParams(
      status: status,
      lowStock: lowStockOnly,
      searchQuery: searchQuery,
    );

    final result = await _getItemsUseCase(params);
    final summaryResult = await _getSummaryUseCase();

    result.fold(
      (failure) => state = ConsumableError(failure.toString()),
      (items) {
        summaryResult.fold(
          (failure) => state = ConsumableError(failure.toString()),
          (summary) => state = ConsumablesLoaded(
            items: items,
            summary: summary,
            filterStatus: status,
            lowStockOnly: lowStockOnly,
            searchQuery: searchQuery,
          ),
        );
      },
    );
  }

  /// البحث في المستهلكات
  Future<void> searchItems(String query) async {
    if (state is ConsumablesLoaded) {
      final currentState = state as ConsumablesLoaded;
      await loadItems(
        status: currentState.filterStatus,
        lowStockOnly: currentState.lowStockOnly,
        searchQuery: query.isEmpty ? null : query,
      );
    } else {
      await loadItems(searchQuery: query.isEmpty ? null : query);
    }
  }

  /// تصفية حسب الحالة
  Future<void> filterByStatus(ConsumableStatus? status) async {
    if (state is ConsumablesLoaded) {
      final currentState = state as ConsumablesLoaded;
      await loadItems(
        status: status,
        lowStockOnly: currentState.lowStockOnly,
        searchQuery: currentState.searchQuery,
      );
    } else {
      await loadItems(status: status);
    }
  }

  /// عرض المخزون المنخفض فقط
  Future<void> showLowStockOnly(bool show) async {
    if (state is ConsumablesLoaded) {
      final currentState = state as ConsumablesLoaded;
      await loadItems(
        status: currentState.filterStatus,
        lowStockOnly: show,
        searchQuery: currentState.searchQuery,
      );
    } else {
      await loadItems(lowStockOnly: show);
    }
  }

  /// فتح نموذج إضافة/تعديل
  void openEditForm(ConsumableItem? item) {
    state = ConsumableEditing(item: item);
  }

  /// إنشاء مستهلك جديد
  Future<void> createItem(CreateConsumableParams params) async {
    state = const ConsumablesLoading();

    final result = await _createItemUseCase(params);

    result.fold(
      (failure) => state = ConsumableError(failure.toString()),
      (item) {
        state = ConsumableSuccess(
          message: 'تم إضافة المستهلك ${item.name} بنجاح',
          item: item,
        );
        loadItems();
      },
    );
  }

  /// تحديث مستهلك
  Future<void> updateItem(UpdateConsumableParams params) async {
    state = const ConsumablesLoading();

    final result = await _updateItemUseCase(params);

    result.fold(
      (failure) => state = ConsumableError(failure.toString()),
      (item) {
        state = ConsumableSuccess(
          message: 'تم تحديث المستهلك ${item.name} بنجاح',
          item: item,
        );
        loadItems();
      },
    );
  }

  /// حذف مستهلك
  Future<void> deleteItem(UniqueId id, String deletedBy) async {
    final params = DeleteConsumableParams(
      id: id,
      deletedBy: deletedBy,
    );

    final result = await _deleteItemUseCase(params);

    result.fold(
      (failure) => state = ConsumableError(failure.toString()),
      (_) {
        state = const ConsumableSuccess(message: 'تم حذف المستهلك بنجاح');
        loadItems();
      },
    );
  }

  /// صرف كمية من المستهلك
  Future<void> issueItem(IssueConsumableParams params) async {
    final itemResult = await _getItemsUseCase(
      GetConsumablesParams(),
    );

    ConsumableItem? item;
    itemResult.fold(
      (_) => null,
      (items) => item = items.firstWhere((i) => i.id == params.consumableId),
    );

    if (item != null) {
      state = ConsumableProcessing(operation: 'issue', item: item!);
    }

    final result = await _issueItemUseCase(params);

    result.fold(
      (failure) => state = ConsumableError(failure.toString()),
      (updatedItem) {
        state = ConsumableSuccess(
          message: 'تم صرف ${params.quantity.value} من ${updatedItem.name}',
          item: updatedItem,
        );
        loadItems();
      },
    );
  }

  /// استلام مخزون
  Future<void> receiveItem(ReceiveConsumableParams params) async {
    final itemResult = await _getItemsUseCase(
      GetConsumablesParams(),
    );

    ConsumableItem? item;
    itemResult.fold(
      (_) => null,
      (items) => item = items.firstWhere((i) => i.id == params.consumableId),
    );

    if (item != null) {
      state = ConsumableProcessing(operation: 'receive', item: item!);
    }

    final result = await _receiveItemUseCase(params);

    result.fold(
      (failure) => state = ConsumableError(failure.toString()),
      (updatedItem) {
        state = ConsumableSuccess(
          message: 'تم استلام ${params.quantity.value} من ${updatedItem.name}',
          item: updatedItem,
        );
        loadItems();
      },
    );
  }

  /// تسوية المخزون
  Future<void> adjustStock(AdjustConsumableStockParams params) async {
    state = const ConsumablesLoading();

    final result = await _adjustStockUseCase(params);

    result.fold(
      (failure) => state = ConsumableError(failure.toString()),
      (updatedItem) {
        state = ConsumableSuccess(
          message: 'تم تسوية مخزون ${updatedItem.name}',
          item: updatedItem,
        );
        loadItems();
      },
    );
  }

  /// مسح حالة الخطأ
  void clearError() {
    if (state is ConsumablesLoaded) {
      final currentState = state as ConsumablesLoaded;
      state = currentState.copyWith();
    } else {
      state = const ConsumablesInitial();
    }
  }

  /// إعادة تحميل
  void refresh() {
    if (state is ConsumablesLoaded) {
      final currentState = state as ConsumablesLoaded;
      loadItems(
        status: currentState.filterStatus,
        lowStockOnly: currentState.lowStockOnly,
        searchQuery: currentState.searchQuery,
      );
    } else {
      loadItems();
    }
  }
}

/// Provider للمدير
final consumablesNotifierProvider =
    StateNotifierProvider<ConsumablesNotifier, ConsumablesState>((ref) {
  return ConsumablesNotifier(
    getItemsUseCase: ref.watch(getConsumablesUseCaseProvider),
    getSummaryUseCase: ref.watch(getConsumablesSummaryUseCaseProvider),
    createItemUseCase: ref.watch(createConsumableUseCaseProvider),
    updateItemUseCase: ref.watch(updateConsumableUseCaseProvider),
    deleteItemUseCase: ref.watch(deleteConsumableUseCaseProvider),
    issueItemUseCase: ref.watch(issueConsumableUseCaseProvider),
    receiveItemUseCase: ref.watch(receiveConsumableUseCaseProvider),
    adjustStockUseCase: ref.watch(adjustConsumableStockUseCaseProvider),
  );
});
