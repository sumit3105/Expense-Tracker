/// Supported currencies with their symbols and names
class Currencies {
  static const Map<String, CurrencyInfo> currencies = {
    'INR': CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    'USD': CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar'),
    'EUR': CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    'GBP': CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound'),
    'JPY': CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    'CNY': CurrencyInfo(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    'AUD': CurrencyInfo(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    'CAD': CurrencyInfo(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
    'CHF': CurrencyInfo(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'),
    'AED': CurrencyInfo(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    'SAR': CurrencyInfo(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
    'SGD': CurrencyInfo(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  };
  
  /// Get currency symbol from code
  static String getSymbol(String code) {
    return currencies[code]?.symbol ?? code;
  }
  
  /// Get currency name from code
  static String getName(String code) {
    return currencies[code]?.name ?? code;
  }
  
  /// Get list of all currency codes
  static List<String> getAllCodes() {
    return currencies.keys.toList();
  }
  
  /// Default currency
  static const String defaultCurrency = 'INR';
}

/// Currency information model
class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });
}
