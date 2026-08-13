class SubcategoryDefinition {
  final String id;
  final String name;

  const SubcategoryDefinition({required this.id, required this.name});
}

class CategoryDefinition {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final List<SubcategoryDefinition> subcategories;

  const CategoryDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.subcategories,
  });
}

class CategoryRegistry {
  static const List<CategoryDefinition> categories = [
    CategoryDefinition(
      id: 'food_dining',
      name: 'Food & Dining',
      icon: 'restaurant',
      colorValue: 0xFFF59E0B,
      subcategories: [
        SubcategoryDefinition(id: 'restaurants', name: 'Restaurants'),
        SubcategoryDefinition(id: 'food_delivery', name: 'Food Delivery'),
        SubcategoryDefinition(id: 'fast_food', name: 'Fast Food'),
        SubcategoryDefinition(id: 'coffee', name: 'Coffee'),
        SubcategoryDefinition(id: 'cafes', name: 'Cafes'),
        SubcategoryDefinition(id: 'desserts', name: 'Desserts'),
        SubcategoryDefinition(id: 'other_food', name: 'Other Food'),
      ],
    ),
    CategoryDefinition(
      id: 'shopping',
      name: 'Shopping',
      icon: 'shopping_bag',
      colorValue: 0xFFEF4444,
      subcategories: [
        SubcategoryDefinition(id: 'ecommerce', name: 'E-commerce'),
        SubcategoryDefinition(id: 'clothing', name: 'Clothing'),
        SubcategoryDefinition(id: 'electronics', name: 'Electronics'),
        SubcategoryDefinition(id: 'beauty', name: 'Beauty'),
        SubcategoryDefinition(id: 'home', name: 'Home'),
        SubcategoryDefinition(id: 'shopping_other', name: 'Other Shopping'),
      ],
    ),
    CategoryDefinition(
      id: 'groceries',
      name: 'Groceries',
      icon: 'local_grocery_store',
      colorValue: 0xFF10B981,
      subcategories: [
        SubcategoryDefinition(id: 'quick_commerce', name: 'Quick Commerce'),
        SubcategoryDefinition(id: 'supermarket', name: 'Supermarket'),
        SubcategoryDefinition(id: 'grocery_store', name: 'Grocery Store'),
        SubcategoryDefinition(id: 'grocery_other', name: 'Other Grocery'),
      ],
    ),
    CategoryDefinition(
      id: 'transport',
      name: 'Ride / Transport',
      icon: 'directions_car',
      colorValue: 0xFF06B6D4,
      subcategories: [
        SubcategoryDefinition(id: 'cab', name: 'Cab'),
        SubcategoryDefinition(id: 'ride_hailing', name: 'Ride Hailing'),
        SubcategoryDefinition(id: 'public_transport', name: 'Public Transport'),
        SubcategoryDefinition(id: 'fuel', name: 'Fuel'),
        SubcategoryDefinition(id: 'parking', name: 'Parking'),
        SubcategoryDefinition(id: 'transport_other', name: 'Other Transport'),
      ],
    ),
    CategoryDefinition(
      id: 'bills_recharge',
      name: 'Bills & Recharge',
      icon: 'receipt_long',
      colorValue: 0xFF8B5CF6,
      subcategories: [
        SubcategoryDefinition(id: 'mobile', name: 'Mobile'),
        SubcategoryDefinition(id: 'internet', name: 'Internet'),
        SubcategoryDefinition(id: 'electricity', name: 'Electricity'),
        SubcategoryDefinition(id: 'water', name: 'Water'),
        SubcategoryDefinition(id: 'gas', name: 'Gas'),
        SubcategoryDefinition(id: 'dth', name: 'DTH'),
        SubcategoryDefinition(id: 'recharge_other', name: 'Other Bills'),
      ],
    ),
    CategoryDefinition(
      id: 'housing',
      name: 'Housing',
      icon: 'home',
      colorValue: 0xFF3F3F46,
      subcategories: [
        SubcategoryDefinition(id: 'house_rent', name: 'House Rent'),
        SubcategoryDefinition(id: 'maintenance', name: 'Maintenance'),
        SubcategoryDefinition(id: 'repairs', name: 'Repairs'),
        SubcategoryDefinition(id: 'furniture', name: 'Furniture'),
        SubcategoryDefinition(id: 'housing_other', name: 'Other Housing'),
      ],
    ),
    CategoryDefinition(
      id: 'entertainment',
      name: 'Entertainment',
      icon: 'sports_esports',
      colorValue: 0xFFEC4899,
      subcategories: [
        SubcategoryDefinition(id: 'streaming', name: 'Streaming'),
        SubcategoryDefinition(id: 'music', name: 'Music'),
        SubcategoryDefinition(id: 'gaming', name: 'Gaming'),
        SubcategoryDefinition(id: 'movies', name: 'Movies'),
        SubcategoryDefinition(id: 'entertainment_other', name: 'Other Entertainment'),
      ],
    ),
    CategoryDefinition(
      id: 'banking_finance',
      name: 'Banking & Finance',
      icon: 'account_balance',
      colorValue: 0xFF0D9488,
      subcategories: [
        SubcategoryDefinition(id: 'bank_charges', name: 'Bank Charges'),
        SubcategoryDefinition(id: 'atm', name: 'ATM'),
        SubcategoryDefinition(id: 'credit_card', name: 'Credit Card'),
        SubcategoryDefinition(id: 'loan', name: 'Loan'),
        SubcategoryDefinition(id: 'investment', name: 'Investment'),
        SubcategoryDefinition(id: 'finance_other', name: 'Other Finance'),
      ],
    ),
    CategoryDefinition(
      id: 'health',
      name: 'Health',
      icon: 'medical_services',
      colorValue: 0xFFEF4444,
      subcategories: [
        SubcategoryDefinition(id: 'pharmacy', name: 'Pharmacy'),
        SubcategoryDefinition(id: 'doctor', name: 'Doctor Consultation'),
        SubcategoryDefinition(id: 'hospital', name: 'Hospital Charge'),
        SubcategoryDefinition(id: 'health_other', name: 'Other Health'),
      ],
    ),
    CategoryDefinition(
      id: 'education',
      name: 'Education',
      icon: 'school',
      colorValue: 0xFF6366F1,
      subcategories: [
        SubcategoryDefinition(id: 'tuition', name: 'Tuition Fees'),
        SubcategoryDefinition(id: 'books', name: 'Books'),
        SubcategoryDefinition(id: 'education_other', name: 'Other Education'),
      ],
    ),
    CategoryDefinition(
      id: 'travel',
      name: 'Travel',
      icon: 'flight',
      colorValue: 0xFF14B8A6,
      subcategories: [
        SubcategoryDefinition(id: 'flight', name: 'Flight Ticket'),
        SubcategoryDefinition(id: 'hotel', name: 'Hotel Stay'),
        SubcategoryDefinition(id: 'travel_other', name: 'Other Travel'),
      ],
    ),
    CategoryDefinition(
      id: 'utilities',
      name: 'Utilities',
      icon: 'settings',
      colorValue: 0xFF64748B,
      subcategories: [
        SubcategoryDefinition(id: 'utilities_other', name: 'Other Utilities'),
      ],
    ),
    CategoryDefinition(
      id: 'transfer',
      name: 'Transfer',
      icon: 'swap_horiz',
      colorValue: 0xFF3B82F6,
      subcategories: [
        SubcategoryDefinition(id: 'bank_transfer', name: 'Bank Transfer'),
        SubcategoryDefinition(id: 'wallet_transfer', name: 'Wallet Transfer'),
      ],
    ),
    CategoryDefinition(
      id: 'salary_income',
      name: 'Salary / Income',
      icon: 'monetization_on',
      colorValue: 0xFF22C55E,
      subcategories: [
        SubcategoryDefinition(id: 'salary', name: 'Salary'),
        SubcategoryDefinition(id: 'freelance', name: 'Freelance'),
        SubcategoryDefinition(id: 'business', name: 'Business'),
        SubcategoryDefinition(id: 'investment_income', name: 'Investment Income'),
        SubcategoryDefinition(id: 'interest', name: 'Interest'),
        SubcategoryDefinition(id: 'gift', name: 'Gift'),
        SubcategoryDefinition(id: 'refund', name: 'Refund'),
        SubcategoryDefinition(id: 'income_other', name: 'Other Income'),
      ],
    ),
    CategoryDefinition(
      id: 'other',
      name: 'Other',
      icon: 'widgets',
      colorValue: 0xFF78716C,
      subcategories: [
        SubcategoryDefinition(id: 'other_expense', name: 'Other Expense'),
      ],
    ),
  ];
}
