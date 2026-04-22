import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:foundation/foundation.dart';
import '../../../application/application.dart';
import '../../../domain/domain.dart';

/// حوار إضافة/تعديل أصل ثابت (Placeholder)
class FixedAssetDialog extends StatelessWidget {
  final FixedAsset? asset;
  final Function(CreateFixedAssetParams) onSave;

  const FixedAssetDialog({
    super.key,
    this.asset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(asset == null ? 'إضافة أصل ثابت' : 'تعديل أصل ثابت'),
      content: const SizedBox(
        width: 400,
        child: Text('نموذج إضافة/تعديل الأصول الثابتة - سيتم تنفيذه قريباً'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            // Placeholder - إنشاء params افتراضية
            final params = CreateFixedAssetParams(
              code: '',
              name: 'أصل جديد',
              categoryId: UniqueId.generate(),
              purchaseDate: DateTime.now(),
              purchaseCost: Money.fromDouble(1000, Currency.syp()),
              currency: Currency.syp(),
              fxRate: MoneyFxRate(
                fromCurrency: Currency.syp(),
                toCurrency: Currency.syp(),
                rate: 1,
                rateDate: DateTime.now(),
              ),
              usefulLifeMonths: 12,
              createdBy: 'system',
            );
            onSave(params);
            Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

/// حوار استبعاد/بيع أصل (Placeholder)
class DisposeAssetDialog extends StatelessWidget {
  final FixedAsset asset;
  final Function(DisposeFixedAssetParams) onDispose;

  const DisposeAssetDialog({
    super.key,
    required this.asset,
    required this.onDispose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('استبعاد/بيع: ${asset.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('القيمة الدفترية: ${asset.netBookValue.amount.toStringAsFixed(2)} ل.س'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'سعر البيع (اختياري)',
                hintText: 'اتركه فارغاً للاستبعاد بدون بيع',
              ),
              keyboardType: TextInputType.number,
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
          onPressed: () {
            final params = DisposeFixedAssetParams(
              id: asset.id,
              disposalDate: DateTime.now(),
              salePrice: null, // Placeholder
              disposedBy: 'system',
            );
            onDispose(params);
            Navigator.pop(context);
          },
          child: const Text('تنفيذ'),
        ),
      ],
    );
  }
}

/// حوار إضافة/تعديل مستهلك (Placeholder)
class ConsumableDialog extends StatelessWidget {
  final ConsumableItem? item;
  final Function(CreateConsumableParams) onSave;

  const ConsumableDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item == null ? 'إضافة مستهلك' : 'تعديل مستهلك'),
      content: const SizedBox(
        width: 400,
        child: Text('نموذج إضافة/تعديل المستهلكات - سيتم تنفيذه قريباً'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final params = CreateConsumableParams(
              code: '',
              name: 'مستهلك جديد',
              categoryId: UniqueId.generate(),
              initialQuantity: Quantity(10, 'unit'),
              unitOfMeasure: Quantity(1, 'unit'),
              unitCost: Money.fromDouble(50, Currency.syp()),
              currency: Currency.syp(),
              fxRate: MoneyFxRate(
                fromCurrency: Currency.syp(),
                toCurrency: Currency.syp(),
                rate: 1,
                rateDate: DateTime.now(),
              ),
              createdBy: 'system',
            );
            onSave(params);
            Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

/// حوار صرف مستهلك (Placeholder)
class IssueConsumableDialog extends StatelessWidget {
  final ConsumableItem item;
  final Function(IssueConsumableParams) onIssue;

  const IssueConsumableDialog({
    super.key,
    required this.item,
    required this.onIssue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('صرف: ${item.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المخزون المتاح: ${item.quantityOnHand.value.toStringAsFixed(0)} ${item.unitOfMeasure.unit}'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'الكمية المراد صرفها *',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'الجهة المستفيدة',
                hintText: 'مثال: مطبخ، تعبئة، إلخ',
              ),
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
          onPressed: () {
            final params = IssueConsumableParams(
              consumableId: item.id,
              quantity: Quantity(1, item.unitOfMeasure.unit),
              issueDate: DateTime.now(),
              department: 'مطبخ', // Placeholder
              issuedBy: 'system',
            );
            onIssue(params);
            Navigator.pop(context);
          },
          child: const Text('صرف'),
        ),
      ],
    );
  }
}

/// حوار استلام مستهلك (Placeholder)
class ReceiveConsumableDialog extends StatelessWidget {
  final ConsumableItem item;
  final Function(ReceiveConsumableParams) onReceive;

  const ReceiveConsumableDialog({
    super.key,
    required this.item,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('استلام: ${item.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المخزون الحالي: ${item.quantityOnHand.value.toStringAsFixed(0)} ${item.unitOfMeasure.unit}'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'الكمية المراد استلامها *',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'تكلفة الوحدة',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'المورد (اختياري)',
              ),
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
          onPressed: () {
            final params = ReceiveConsumableParams(
              consumableId: item.id,
              quantity: Quantity(10, item.unitOfMeasure.unit),
              unitCost: item.unitCost,
              currency: item.currency,
              fxRate: item.fxRate,
              receiveDate: DateTime.now(),
              supplierName: 'مورد عام', // Placeholder
              receivedBy: 'system',
            );
            onReceive(params);
            Navigator.pop(context);
          },
          child: const Text('استلام'),
        ),
      ],
    );
  }
}
