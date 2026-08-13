import 'package:intl/intl.dart';

enum CurrencyType { inr, usd, eur, gbp }

class CurrencyUtils {
  CurrencyUtils._();

  static bool privacyMode = false;
  static bool hideTransactionAmounts = false;

  static String getSymbol(CurrencyType type) {
    switch (type) {
      case CurrencyType.inr:
        return '₹';
      case CurrencyType.usd:
        return '\$';
      case CurrencyType.eur:
        return '€';
      case CurrencyType.gbp:
        return '£';
    }
  }

  static String format(double amount, {CurrencyType type = CurrencyType.inr, bool isTransaction = false}) {
    final format = NumberFormat.currency(
      locale: type == CurrencyType.inr ? 'en_IN' : 'en_US',
      symbol: getSymbol(type),
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    final formatted = format.format(amount);
    if (privacyMode || (isTransaction && hideTransactionAmounts)) {
      final buffer = StringBuffer();
      for (var i = 0; i < formatted.length; i++) {
        final char = formatted[i];
        if (char == '-' || char == '+' || char == '₹' || char == '\$' || char == '€' || char == '£') {
          buffer.write(char);
        } else {
          if (buffer.length < 5) {
            buffer.write('•');
          }
        }
      }
      return buffer.toString();
    }
    return formatted;
  }

  static String formatCompact(double amount, {CurrencyType type = CurrencyType.inr}) {
    if (privacyMode) {
      return format(amount, type: type);
    }
    final symbol = getSymbol(type);
    if (amount >= 10000000) {
      final val = amount / 10000000;
      return '$symbol${val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      final val = amount / 100000;
      return '$symbol${val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      final val = amount / 1000;
      return '$symbol${val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(1)}K';
    }
    return format(amount, type: type);
  }
}
