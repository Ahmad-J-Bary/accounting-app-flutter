import 'package:flutter/material.dart';
import 'package:design_system/src/colors/app_colors.dart';

class AppTableColumn<T> {
  final String label;
  final T Function(T data) cellValue;
  final double? width;
  final bool isNumeric;

  AppTableColumn({
    required this.label,
    required this.cellValue,
    this.width,
    this.isNumeric = false,
  });
}

class AppTable<T> extends StatelessWidget {
  final List<AppTableColumn<T>> columns;
  final List<T> data;
  final void Function(T item)? onRowTap;
  final Widget? emptyWidget;

  const AppTable({
    super.key,
    required this.columns,
    required this.data,
    this.onRowTap,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return emptyWidget ??
          Center(
            child: Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns
              .map((col) => DataColumn(
                    label: Text(
                      col.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    numeric: col.isNumeric,
                  ))
              .toList(),
          rows: data.map((item) {
            return DataRow(
              cells: columns
                  .map((col) => DataCell(
                        Text(col.cellValue(item).toString()),
                      ))
                  .toList(),
              onSelectChanged: onRowTap != null
                  ? (selected) {
                      if (selected == true) {
                        onRowTap!(item);
                      }
                    }
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}
