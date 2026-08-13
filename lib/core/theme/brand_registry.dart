import '../theme/entities.dart';

class BrandRegistry {
  static final List<MerchantEntity> merchants = [
    // Shopping
    MerchantEntity(id: 'amazon', categoryId: 'shopping', name: 'Amazon', brandKey: 'amazon', iconAsset: 'assets/brands/amazon.png', isDefault: true),
    MerchantEntity(id: 'flipkart', categoryId: 'shopping', name: 'Flipkart', brandKey: 'flipkart', iconAsset: 'assets/brands/flipkart.png'),
    MerchantEntity(id: 'myntra', categoryId: 'shopping', name: 'Myntra', brandKey: 'myntra', iconAsset: 'assets/brands/myntra.png'),
    MerchantEntity(id: 'meesho', categoryId: 'shopping', name: 'Meesho', brandKey: 'meesho', iconAsset: 'assets/brands/meesho.png'),
    MerchantEntity(id: 'ajio', categoryId: 'shopping', name: 'AJIO', brandKey: 'ajio', iconAsset: 'assets/brands/ajio.png'),
    MerchantEntity(id: 'savana', categoryId: 'shopping', name: 'Savana', brandKey: 'savana', iconAsset: 'assets/brands/savana.png'),
    MerchantEntity(id: 'nykaa', categoryId: 'shopping', name: 'Nykaa', brandKey: 'nykaa', iconAsset: 'assets/brands/nykaa.png'),
    MerchantEntity(id: 'tatacliq', categoryId: 'shopping', name: 'Tata CLiQ', brandKey: 'tatacliq', iconAsset: 'assets/brands/tatacliq.png'),
    MerchantEntity(id: 'snapdeal', categoryId: 'shopping', name: 'Snapdeal', brandKey: 'snapdeal', iconAsset: 'assets/brands/snapdeal.png'),
    MerchantEntity(id: 'other_shopping', categoryId: 'shopping', name: 'Other Shopping', brandKey: 'other_shopping'),

    // Food & Dining
    MerchantEntity(id: 'swiggy', categoryId: 'food_dining', name: 'Swiggy', brandKey: 'swiggy', iconAsset: 'assets/brands/swiggy.png', isDefault: true),
    MerchantEntity(id: 'zomato', categoryId: 'food_dining', name: 'Zomato', brandKey: 'zomato', iconAsset: 'assets/brands/zomato.png'),
    MerchantEntity(id: 'starbucks', categoryId: 'food_dining', name: 'Starbucks', brandKey: 'starbucks', iconAsset: 'assets/brands/starbucks.png'),
    MerchantEntity(id: 'mcdonalds', categoryId: 'food_dining', name: "McDonald's", brandKey: 'mcdonalds', iconAsset: 'assets/brands/mcdonalds.png'),
    MerchantEntity(id: 'kfc', categoryId: 'food_dining', name: 'KFC', brandKey: 'kfc', iconAsset: 'assets/brands/kfc.png'),
    MerchantEntity(id: 'dominos', categoryId: 'food_dining', name: "Domino's", brandKey: 'dominos', iconAsset: 'assets/brands/dominos.png'),
    MerchantEntity(id: 'pizzahut', categoryId: 'food_dining', name: 'Pizza Hut', brandKey: 'pizzahut', iconAsset: 'assets/brands/pizzahut.png'),
    MerchantEntity(id: 'burgerking', categoryId: 'food_dining', name: 'Burger King', brandKey: 'burgerking', iconAsset: 'assets/brands/burgerking.png'),
    MerchantEntity(id: 'other_food', categoryId: 'food_dining', name: 'Other Food', brandKey: 'other_food'),

    // Groceries
    MerchantEntity(id: 'blinkit', categoryId: 'groceries', name: 'Blinkit', brandKey: 'blinkit', iconAsset: 'assets/brands/blinkit.png', isDefault: true),
    MerchantEntity(id: 'zepto', categoryId: 'groceries', name: 'Zepto', brandKey: 'zepto', iconAsset: 'assets/brands/zepto.png'),
    MerchantEntity(id: 'instamart', categoryId: 'groceries', name: 'Instamart', brandKey: 'instamart', iconAsset: 'assets/brands/instamart.png'),
    MerchantEntity(id: 'bigbasket', categoryId: 'groceries', name: 'BigBasket', brandKey: 'bigbasket', iconAsset: 'assets/brands/bigbasket.png'),
    MerchantEntity(id: 'jiomart', categoryId: 'groceries', name: 'JioMart', brandKey: 'jiomart', iconAsset: 'assets/brands/jiomart.png'),
    MerchantEntity(id: 'dmart', categoryId: 'groceries', name: 'DMart', brandKey: 'dmart', iconAsset: 'assets/brands/dmart.png'),
    MerchantEntity(id: 'other_grocery', categoryId: 'groceries', name: 'Other Grocery', brandKey: 'other_grocery'),

    // Ride / Transport
    MerchantEntity(id: 'uber', categoryId: 'ride_transport', name: 'Uber', brandKey: 'uber', iconAsset: 'assets/brands/uber.png', isDefault: true),
    MerchantEntity(id: 'ola', categoryId: 'ride_transport', name: 'Ola', brandKey: 'ola', iconAsset: 'assets/brands/ola.png'),
    MerchantEntity(id: 'rapido', categoryId: 'ride_transport', name: 'Rapido', brandKey: 'rapido', iconAsset: 'assets/brands/rapido.png'),
    MerchantEntity(id: 'redbus', categoryId: 'ride_transport', name: 'RedBus', brandKey: 'redbus', iconAsset: 'assets/brands/redbus.png'),
    MerchantEntity(id: 'metro', categoryId: 'ride_transport', name: 'Metro', brandKey: 'metro', iconAsset: 'assets/brands/metro.png'),
    MerchantEntity(id: 'bus', categoryId: 'ride_transport', name: 'Bus', brandKey: 'bus'),
    MerchantEntity(id: 'train', categoryId: 'ride_transport', name: 'Train', brandKey: 'train'),
    MerchantEntity(id: 'fuel', categoryId: 'ride_transport', name: 'Petrol / Diesel', brandKey: 'fuel'),
    MerchantEntity(id: 'parking', categoryId: 'ride_transport', name: 'Parking', brandKey: 'parking'),
    MerchantEntity(id: 'other_transport', categoryId: 'ride_transport', name: 'Other Transport', brandKey: 'other_transport'),

    // Bills & Recharge
    MerchantEntity(id: 'airtel', categoryId: 'bills_recharge', name: 'Airtel Mobile', brandKey: 'airtel', iconAsset: 'assets/brands/airtel.png', isDefault: true),
    MerchantEntity(id: 'jio', categoryId: 'bills_recharge', name: 'Jio Mobile', brandKey: 'jio', iconAsset: 'assets/brands/jio.png'),
    MerchantEntity(id: 'vi', categoryId: 'bills_recharge', name: 'Vi Mobile', brandKey: 'vi', iconAsset: 'assets/brands/vi.png'),
    MerchantEntity(id: 'bsnl', categoryId: 'bills_recharge', name: 'BSNL Mobile', brandKey: 'bsnl', iconAsset: 'assets/brands/bsnl.png'),
    MerchantEntity(id: 'tataplay', categoryId: 'bills_recharge', name: 'Tata Play DTH', brandKey: 'tataplay', iconAsset: 'assets/brands/tataplay.png'),
    MerchantEntity(id: 'airtel_xstream', categoryId: 'bills_recharge', name: 'Airtel Xstream Broadband', brandKey: 'airtel_xstream', iconAsset: 'assets/brands/airtel.png'),
    MerchantEntity(id: 'jiofiber', categoryId: 'bills_recharge', name: 'JioFiber Broadband', brandKey: 'jiofiber', iconAsset: 'assets/brands/jio.png'),
    MerchantEntity(id: 'act_fibernet', categoryId: 'bills_recharge', name: 'ACT Fibernet Broadband', brandKey: 'act_fibernet', iconAsset: 'assets/brands/act.png'),
    MerchantEntity(id: 'electricity', categoryId: 'bills_recharge', name: 'Electricity Bill', brandKey: 'electricity'),
    MerchantEntity(id: 'water_bill', categoryId: 'bills_recharge', name: 'Water Bill', brandKey: 'water_bill'),
    MerchantEntity(id: 'gas', categoryId: 'bills_recharge', name: 'LPG / Gas Bill', brandKey: 'gas'),
    MerchantEntity(id: 'credit_card_bill', categoryId: 'bills_recharge', name: 'Credit Card Bill', brandKey: 'credit_card_bill'),
    MerchantEntity(id: 'insurance', categoryId: 'bills_recharge', name: 'Insurance Premium', brandKey: 'insurance'),
    MerchantEntity(id: 'other_bills', categoryId: 'bills_recharge', name: 'Other Bills', brandKey: 'other_bills'),

    // Housing
    MerchantEntity(id: 'house_rent', categoryId: 'housing', name: 'House Rent', brandKey: 'house_rent', isDefault: true),
    MerchantEntity(id: 'room_rent', categoryId: 'housing', name: 'Room Rent', brandKey: 'room_rent'),
    MerchantEntity(id: 'maintenance', categoryId: 'housing', name: 'Maintenance', brandKey: 'maintenance'),
    MerchantEntity(id: 'society_maintenance', categoryId: 'housing', name: 'Society Maintenance', brandKey: 'society_maintenance'),
    MerchantEntity(id: 'security_deposit', categoryId: 'housing', name: 'Security Deposit', brandKey: 'security_deposit'),
    MerchantEntity(id: 'furniture', categoryId: 'housing', name: 'Furniture', brandKey: 'furniture'),
    MerchantEntity(id: 'appliances', categoryId: 'housing', name: 'Appliances', brandKey: 'appliances'),
    MerchantEntity(id: 'other_housing', categoryId: 'housing', name: 'Other Housing', brandKey: 'other_housing'),

    // Banking & Finance
    MerchantEntity(id: 'hdfc_bank', categoryId: 'banking_finance', name: 'HDFC Bank', brandKey: 'hdfc_bank', iconAsset: 'assets/brands/hdfc.png', isDefault: true),
    MerchantEntity(id: 'sbi', categoryId: 'banking_finance', name: 'State Bank of India', brandKey: 'sbi', iconAsset: 'assets/brands/sbi.png'),
    MerchantEntity(id: 'icici_bank', categoryId: 'banking_finance', name: 'ICICI Bank', brandKey: 'icici_bank', iconAsset: 'assets/brands/icici.png'),
    MerchantEntity(id: 'axis_bank', categoryId: 'banking_finance', name: 'Axis Bank', brandKey: 'axis_bank', iconAsset: 'assets/brands/axis.png'),
    MerchantEntity(id: 'kotak_bank', categoryId: 'banking_finance', name: 'Kotak Mahindra Bank', brandKey: 'kotak_bank', iconAsset: 'assets/brands/kotak.png'),
    MerchantEntity(id: 'idfc_bank', categoryId: 'banking_finance', name: 'IDFC FIRST Bank', brandKey: 'idfc_bank', iconAsset: 'assets/brands/idfc.png'),
    MerchantEntity(id: 'yes_bank', categoryId: 'banking_finance', name: 'Yes Bank', brandKey: 'yes_bank', iconAsset: 'assets/brands/yes.png'),
    MerchantEntity(id: 'indusind_bank', categoryId: 'banking_finance', name: 'IndusInd Bank', brandKey: 'indusind_bank', iconAsset: 'assets/brands/indusind.png'),
    MerchantEntity(id: 'bob_bank', categoryId: 'banking_finance', name: 'Bank of Baroda', brandKey: 'bob_bank', iconAsset: 'assets/brands/bob.png'),
    MerchantEntity(id: 'pnb_bank', categoryId: 'banking_finance', name: 'Punjab National Bank', brandKey: 'pnb_bank', iconAsset: 'assets/brands/pnb.png'),
    MerchantEntity(id: 'canara_bank', categoryId: 'banking_finance', name: 'Canara Bank', brandKey: 'canara_bank', iconAsset: 'assets/brands/canara.png'),
    MerchantEntity(id: 'union_bank', categoryId: 'banking_finance', name: 'Union Bank', brandKey: 'union_bank', iconAsset: 'assets/brands/union.png'),
    MerchantEntity(id: 'cash', categoryId: 'banking_finance', name: 'Cash Withdrawal', brandKey: 'cash'),
    MerchantEntity(id: 'upi', categoryId: 'banking_finance', name: 'UPI transaction', brandKey: 'upi'),
    MerchantEntity(id: 'other_finance', categoryId: 'banking_finance', name: 'Other Finance', brandKey: 'other_finance'),

    // Transfer
    MerchantEntity(id: 'bank_transfer', categoryId: 'transfer', name: 'Bank Transfer', brandKey: 'bank_transfer', isDefault: true),
    MerchantEntity(id: 'account_transfer', categoryId: 'transfer', name: 'Account Transfer', brandKey: 'account_transfer'),
    MerchantEntity(id: 'upi_transfer', categoryId: 'transfer', name: 'UPI Transfer', brandKey: 'upi_transfer'),
    MerchantEntity(id: 'cash_transfer', categoryId: 'transfer', name: 'Cash Transfer', brandKey: 'cash_transfer'),
    MerchantEntity(id: 'credit_card_payment', categoryId: 'transfer', name: 'Credit Card Payment', brandKey: 'credit_card_payment'),

    // Payments
    MerchantEntity(id: 'phonepe', categoryId: 'banking_finance', name: 'PhonePe', brandKey: 'phonepe', iconAsset: 'assets/brands/phonepe.png'),
    MerchantEntity(id: 'gpay', categoryId: 'banking_finance', name: 'Google Pay', brandKey: 'gpay', iconAsset: 'assets/brands/gpay.png'),
    MerchantEntity(id: 'paytm', categoryId: 'banking_finance', name: 'Paytm', brandKey: 'paytm', iconAsset: 'assets/brands/paytm.png'),
    MerchantEntity(id: 'cred', categoryId: 'banking_finance', name: 'CRED', brandKey: 'cred', iconAsset: 'assets/brands/cred.png'),

    // Entertainment
    MerchantEntity(id: 'netflix', categoryId: 'entertainment', name: 'Netflix', brandKey: 'netflix', iconAsset: 'assets/brands/netflix.png', isDefault: true),
    MerchantEntity(id: 'spotify', categoryId: 'entertainment', name: 'Spotify', brandKey: 'spotify', iconAsset: 'assets/brands/spotify.png'),
    MerchantEntity(id: 'youtube_premium', categoryId: 'entertainment', name: 'YouTube Premium', brandKey: 'youtube_premium', iconAsset: 'assets/brands/youtube.png'),
    MerchantEntity(id: 'amazon_prime', categoryId: 'entertainment', name: 'Amazon Prime', brandKey: 'amazon_prime', iconAsset: 'assets/brands/amazon_prime.png'),
    MerchantEntity(id: 'disney_hotstar', categoryId: 'entertainment', name: 'JioHotstar', brandKey: 'disney_hotstar', iconAsset: 'assets/brands/hotstar.png'),
    MerchantEntity(id: 'sony_liv', categoryId: 'entertainment', name: 'Sony LIV', brandKey: 'sony_liv', iconAsset: 'assets/brands/sonyliv.png'),
    MerchantEntity(id: 'zee5', categoryId: 'entertainment', name: 'ZEE5', brandKey: 'zee5', iconAsset: 'assets/brands/zee5.png'),
    MerchantEntity(id: 'gaming', categoryId: 'entertainment', name: 'Gaming / Arcade', brandKey: 'gaming'),
    MerchantEntity(id: 'movies', categoryId: 'entertainment', name: 'Movies / Cinema', brandKey: 'movies'),
    MerchantEntity(id: 'other_entertainment', categoryId: 'entertainment', name: 'Other Entertainment', brandKey: 'other_entertainment'),

    // Health
    MerchantEntity(id: 'pharmacy', categoryId: 'health', name: 'Pharmacy / Medicine', brandKey: 'pharmacy', isDefault: true),
    MerchantEntity(id: 'hospital', categoryId: 'health', name: 'Hospital Charge', brandKey: 'hospital'),
    MerchantEntity(id: 'doctor', categoryId: 'health', name: 'Doctor Consultation', brandKey: 'doctor'),
    MerchantEntity(id: 'medical_test', categoryId: 'health', name: 'Lab Test', brandKey: 'medical_test'),
    MerchantEntity(id: 'health_insurance', categoryId: 'health', name: 'Health Insurance', brandKey: 'health_insurance'),
    MerchantEntity(id: 'gym', categoryId: 'health', name: 'Gym / Fitness Club', brandKey: 'gym'),
    MerchantEntity(id: 'other_health', categoryId: 'health', name: 'Other Health', brandKey: 'other_health'),

    // Education
    MerchantEntity(id: 'school_fee', categoryId: 'education', name: 'School Fee', brandKey: 'school_fee', isDefault: true),
    MerchantEntity(id: 'college_fee', categoryId: 'education', name: 'College Fee', brandKey: 'college_fee'),
    MerchantEntity(id: 'udemy', categoryId: 'education', name: 'Udemy Course', brandKey: 'udemy', iconAsset: 'assets/brands/udemy.png'),
    MerchantEntity(id: 'coursera', categoryId: 'education', name: 'Coursera Subscription', brandKey: 'coursera', iconAsset: 'assets/brands/coursera.png'),
    MerchantEntity(id: 'books', categoryId: 'education', name: 'Books / Stationery', brandKey: 'books'),
    MerchantEntity(id: 'exam_fee', categoryId: 'education', name: 'Exam Registration Fee', brandKey: 'exam_fee'),
    MerchantEntity(id: 'other_education', categoryId: 'education', name: 'Other Education', brandKey: 'other_education'),

    // Travel
    MerchantEntity(id: 'makemytrip', categoryId: 'travel', name: 'MakeMyTrip', brandKey: 'makemytrip', iconAsset: 'assets/brands/makemytrip.png', isDefault: true),
    MerchantEntity(id: 'goibibo', categoryId: 'travel', name: 'Goibibo', brandKey: 'goibibo', iconAsset: 'assets/brands/goibibo.png'),
    MerchantEntity(id: 'booking_com', categoryId: 'travel', name: 'Booking.com', brandKey: 'booking_com', iconAsset: 'assets/brands/booking.png'),
    MerchantEntity(id: 'airbnb', categoryId: 'travel', name: 'Airbnb', brandKey: 'airbnb', iconAsset: 'assets/brands/airbnb.png'),
    MerchantEntity(id: 'irctc', categoryId: 'travel', name: 'IRCTC Railway Booking', brandKey: 'irctc', iconAsset: 'assets/brands/irctc.png'),
    MerchantEntity(id: 'flight', categoryId: 'travel', name: 'Flight Ticket', brandKey: 'flight'),
    MerchantEntity(id: 'hotel', categoryId: 'travel', name: 'Hotel stay', brandKey: 'hotel'),
    MerchantEntity(id: 'other_travel', categoryId: 'travel', name: 'Other Travel', brandKey: 'other_travel'),

    // Extra specific mappings
    MerchantEntity(id: 'amazon_fresh', categoryId: 'groceries', name: 'Amazon Fresh', brandKey: 'amazon_fresh', iconAsset: 'assets/brands/amazon.png'),
  ];

  static final List<CategoryEntity> categories = [
    CategoryEntity(id: 'transfer', name: 'Transfer', icon: 'swap_horiz', colorValue: 0xFF3B82F6, type: TransactionType.transfer, sortOrder: 1),
    CategoryEntity(id: 'shopping', name: 'Shopping', icon: 'shopping_bag', colorValue: 0xFFEF4444, type: TransactionType.expense, sortOrder: 2),
    CategoryEntity(id: 'food_dining', name: 'Food & Dining', icon: 'restaurant', colorValue: 0xFFF59E0B, type: TransactionType.expense, sortOrder: 3),
    CategoryEntity(id: 'groceries', name: 'Groceries', icon: 'local_grocery_store', colorValue: 0xFF10B981, type: TransactionType.expense, sortOrder: 4),
    CategoryEntity(id: 'ride_transport', name: 'Ride / Transport', icon: 'directions_car', colorValue: 0xFF06B6D4, type: TransactionType.expense, sortOrder: 5),
    CategoryEntity(id: 'bills_recharge', name: 'Bills & Recharge', icon: 'receipt_long', colorValue: 0xFF8B5CF6, type: TransactionType.expense, sortOrder: 6),
    CategoryEntity(id: 'housing', name: 'Housing', icon: 'home', colorValue: 0xFF3F3F46, type: TransactionType.expense, sortOrder: 7),
    CategoryEntity(id: 'banking_finance', name: 'Banking & Finance', icon: 'account_balance', colorValue: 0xFF0D9488, type: TransactionType.expense, sortOrder: 8),
    CategoryEntity(id: 'entertainment', name: 'Entertainment', icon: 'sports_esports', colorValue: 0xFFEC4899, type: TransactionType.expense, sortOrder: 9),
    CategoryEntity(id: 'health', name: 'Health', icon: 'medical_services', colorValue: 0xFFEF4444, type: TransactionType.expense, sortOrder: 10),
    CategoryEntity(id: 'education', name: 'Education', icon: 'school', colorValue: 0xFF6366F1, type: TransactionType.expense, sortOrder: 11),
    CategoryEntity(id: 'travel', name: 'Travel', icon: 'flight', colorValue: 0xFF14B8A6, type: TransactionType.expense, sortOrder: 12),
    CategoryEntity(id: 'utilities', name: 'Utilities', icon: 'settings', colorValue: 0xFF64748B, type: TransactionType.expense, sortOrder: 13),
    CategoryEntity(id: 'salary_income', name: 'Salary / Income', icon: 'monetization_on', colorValue: 0xFF22C55E, type: TransactionType.income, sortOrder: 14),
    CategoryEntity(id: 'other', name: 'Other', icon: 'widgets', colorValue: 0xFF78716C, type: TransactionType.expense, sortOrder: 15),
  ];

  static Map<String, dynamic>? detectBrand(String title) {
    final clean = title.trim().toLowerCase();

    // Check specific priority compound cases first
    if (clean.contains('amazon prime') || clean.contains('prime video') || clean.contains('prime subscription')) {
      return {
        'categoryId': 'entertainment',
        'merchantId': 'amazon_prime',
        'brandKey': 'amazon_prime',
        'merchantName': 'Amazon Prime',
      };
    }
    if (clean.contains('amazon fresh')) {
      return {
        'categoryId': 'groceries',
        'merchantId': 'amazon_fresh',
        'brandKey': 'amazon_fresh',
        'merchantName': 'Amazon Fresh',
      };
    }
    if (clean.contains('amazon') || clean.contains('amazon.in')) {
      return {
        'categoryId': 'shopping',
        'merchantId': 'amazon',
        'brandKey': 'amazon',
        'merchantName': 'Amazon',
      };
    }

    // Loop through brand entries
    for (var m in merchants) {
      if (m.brandKey != null) {
        final key = m.brandKey!;
        // Simple keywords checking
        if (clean.contains(key) ||
            clean.contains(m.name.toLowerCase()) ||
            (key == 'tatacliq' && clean.contains('tata cliq')) ||
            (key == 'mcdonalds' && (clean.contains('mcdonald') || clean.contains('mcd'))) ||
            (key == 'dominos' && clean.contains('domino')) ||
            (key == 'pizzahut' && clean.contains('pizza hut')) ||
            (key == 'burgerking' && clean.contains('burger king')) ||
            (key == 'bigbasket' && clean.contains('big basket')) ||
            (key == 'jiomart' && clean.contains('jio mart')) ||
            (key == 'redbus' && clean.contains('red bus')) ||
            (key == 'airtel_xstream' && clean.contains('xstream')) ||
            (key == 'act_fibernet' && clean.contains('act fiber')) ||
            (key == 'credit_card_bill' && clean.contains('credit card')) ||
            (key == 'house_rent' && clean.contains('house rent')) ||
            (key == 'room_rent' && clean.contains('room rent')) ||
            (key == 'society_maintenance' && clean.contains('society')) ||
            (key == 'hdfc_bank' && clean.contains('hdfc')) ||
            (key == 'sbi' && (clean.contains('sbi') || clean.contains('state bank'))) ||
            (key == 'icici_bank' && clean.contains('icici')) ||
            (key == 'axis_bank' && clean.contains('axis')) ||
            (key == 'kotak_bank' && clean.contains('kotak')) ||
            (key == 'idfc_bank' && clean.contains('idfc')) ||
            (key == 'youtube_premium' && clean.contains('youtube')) ||
            (key == 'disney_hotstar' && (clean.contains('hotstar') || clean.contains('disney') || clean.contains('jiohotstar')))) {
          
          return {
            'categoryId': m.categoryId,
            'merchantId': m.id,
            'brandKey': key,
            'merchantName': m.name,
          };
        }
      }
    }
    return null;
  }
}
