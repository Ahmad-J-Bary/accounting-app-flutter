import 'package:equatable/equatable.dart';

class DateRange extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({
    required this.startDate,
    required this.endDate,
  }) : assert(!startDate.isAfter(endDate), 'Start date must be before end date');

  bool get isToday => _isSameDay(startDate, DateTime.now()) && _isSameDay(endDate, DateTime.now());
  bool get isThisWeek => _isThisWeek(startDate) && _isThisWeek(endDate);
  bool get isThisMonth => _isThisMonth(startDate) && _isThisMonth(endDate);
  bool get isThisYear => startDate.year == DateTime.now().year && endDate.year == DateTime.now().year;

  Duration get duration => endDate.difference(startDate);
  int get days => duration.inDays;
  int get hours => duration.inHours;

  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) => DateRange(
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
  );

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return date.isAfter(weekStart) && date.isBefore(weekEnd);
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  @override
  List<Object?> get props => [startDate, endDate];
}
