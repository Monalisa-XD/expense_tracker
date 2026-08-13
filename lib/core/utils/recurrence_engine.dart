import '../theme/entities.dart';

class RecurrenceEngine {
  RecurrenceEngine._();

  static DateTime calculateNextOccurrence(DateTime current, RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return current.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return current.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        int year = current.year;
        int month = current.month + 1;
        if (month > 12) {
          month = 1;
          year++;
        }
        int day = current.day;
        int maxDays = _daysInMonth(year, month);
        if (day > maxDays) {
          day = maxDays;
        }
        return DateTime(year, month, day, current.hour, current.minute, current.second);
      case RecurringFrequency.quarterly:
        int year = current.year;
        int month = current.month + 3;
        if (month > 12) {
          month = month - 12;
          year++;
        }
        int day = current.day;
        int maxDays = _daysInMonth(year, month);
        if (day > maxDays) {
          day = maxDays;
        }
        return DateTime(year, month, day, current.hour, current.minute, current.second);
      case RecurringFrequency.halfYearly:
        int year = current.year;
        int month = current.month + 6;
        if (month > 12) {
          month = month - 12;
          year++;
        }
        int day = current.day;
        int maxDays = _daysInMonth(year, month);
        if (day > maxDays) {
          day = maxDays;
        }
        return DateTime(year, month, day, current.hour, current.minute, current.second);
      case RecurringFrequency.yearly:
        int year = current.year + 1;
        int month = current.month;
        int day = current.day;
        int maxDays = _daysInMonth(year, month);
        if (day > maxDays) {
          day = maxDays;
        }
        return DateTime(year, month, day, current.hour, current.minute, current.second);
      case RecurringFrequency.custom:
        // Default custom to 30 days
        return current.add(const Duration(days: 30));
    }
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeap ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  static List<DateTime> generateDueDates({
    required DateTime startDate,
    required DateTime? endDate,
    required RecurringFrequency frequency,
    required DateTime lastGenerated,
    required DateTime today,
    required List<String> skippedOccurrences,
  }) {
    final List<DateTime> dueDates = [];
    DateTime candidate = lastGenerated;
    const int maxOccurrences = 12;

    while (dueDates.length < maxOccurrences) {
      candidate = calculateNextOccurrence(candidate, frequency);
      
      if (candidate.isAfter(today)) {
        break;
      }

      if (endDate != null && candidate.isAfter(endDate)) {
        break;
      }

      final candidateStr = candidate.toIso8601String().split('T')[0];
      final isSkipped = skippedOccurrences.any((s) => s.startsWith(candidateStr));

      if (!isSkipped) {
        dueDates.add(candidate);
      }
    }
    
    return dueDates;
  }
}
