import 'package:equatable/equatable.dart';
import '../../../domain/domain.dart';

/// حالات شاشة المستهلكات
abstract class ConsumablesState extends Equatable {
  const ConsumablesState();
  
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class ConsumablesInitial extends ConsumablesState {
  const ConsumablesInitial();
}

/// جاري التحميل
class ConsumablesLoading extends ConsumablesState {
  const ConsumablesLoading();
}

/// تم التحميل بنجاح
class ConsumablesLoaded extends ConsumablesState {
  final List<ConsumableItem> items;
  final ConsumablesSummary? summary;
  final ConsumableStatus? filterStatus;
  final bool? lowStockOnly;
  final String? searchQuery;

  const ConsumablesLoaded({
    required this.items,
    this.summary,
    this.filterStatus,
    this.lowStockOnly,
    this.searchQuery,
  });

  ConsumablesLoaded copyWith({
    List<ConsumableItem>? items,
    ConsumablesSummary? summary,
    ConsumableStatus? filterStatus,
    bool? lowStockOnly,
    String? searchQuery,
  }) {
    return ConsumablesLoaded(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      filterStatus: filterStatus ?? this.filterStatus,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [items, summary, filterStatus, lowStockOnly, searchQuery];
}

/// حالة التعديل
class ConsumableEditing extends ConsumablesState {
  final ConsumableItem? item; // null if creating new
  final bool isLoading;
  final String? error;

  const ConsumableEditing({
    this.item,
    this.isLoading = false,
    this.error,
  });

  ConsumableEditing copyWith({
    ConsumableItem? item,
    bool? isLoading,
    String? error,
  }) {
    return ConsumableEditing(
      item: item ?? this.item,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [item, isLoading, error];
}

/// حالة الصرف/الاستلام
class ConsumableProcessing extends ConsumablesState {
  final String operation; // 'issue', 'receive', 'adjust'
  final ConsumableItem item;

  const ConsumableProcessing({
    required this.operation,
    required this.item,
  });

  @override
  List<Object?> get props => [operation, item];
}

/// تمت العملية بنجاح
class ConsumableSuccess extends ConsumablesState {
  final String message;
  final ConsumableItem? item;

  const ConsumableSuccess({
    required this.message,
    this.item,
  });

  @override
  List<Object?> get props => [message, item];
}

/// حالة الخطأ
class ConsumableError extends ConsumablesState {
  final String message;

  const ConsumableError(this.message);

  @override
  List<Object?> get props => [message];
}
