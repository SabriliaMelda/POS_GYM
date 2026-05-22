class AppColors {
  // Primary Colors
  static const int primaryColor = 0xFF2196F3;
  static const int primaryDark = 0xFF1976D2;
  static const int primaryLight = 0xFF64B5F6;

  // Secondary Colors
  static const int secondaryColor = 0xFF03DAC6;
  static const int secondaryDark = 0xFF018786;

  // Accent Colors
  static const int accentColor = 0xFFFF5722;

  // Neutral Colors
  static const int white = 0xFFFFFFFF;
  static const int black = 0xFF000000;
  static const int grey = 0xFF757575;
  static const int lightGrey = 0xFFEEEEEE;
  static const int darkGrey = 0xFF424242;

  // Status Colors
  static const int successColor = 0xFF4CAF50;
  static const int errorColor = 0xFFF44336;
  static const int warningColor = 0xFFFFC107;
  static const int infoColor = 0xFF2196F3;

  // Other Colors
  static const int backgroundColor = 0xFFFAFAFA;
  static const int cardColor = 0xFFFFFFFF;
  static const int dividerColor = 0xFFE0E0E0;
}

class AppFontSizes {
  static const double titleLarge = 32.0;
  static const double titleMedium = 28.0;
  static const double titleSmall = 22.0;
  static const double headingLarge = 20.0;
  static const double headingMedium = 18.0;
  static const double headingSmall = 16.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
}

class AppPadding {
  static const double extraSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

class AppRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class TransactionStatus {
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String failed = 'failed';
}

class PaymentMethods {
  static const String cash = 'cash';
  static const String edc = 'edc';
  static const String qris = 'qris';
  static const String transfer = 'transfer';
  static const String creditCard = 'credit_card';
}

class TransactionTypes {
  static const String gymPackage = 'gym_package';
  static const String foodBeverage = 'food_beverage';
  static const String membership = 'membership';
  static const String renewal = 'renewal';
}
