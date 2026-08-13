class MerchantDefinition {
  final String id;
  final String name;
  final String categoryId;
  final String subcategoryId;
  final String? brandKey;
  final String? iconAsset;
  final List<String> keywords;

  const MerchantDefinition({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subcategoryId,
    this.brandKey,
    this.iconAsset,
    required this.keywords,
  });
}

class MerchantRegistry {
  static const List<MerchantDefinition> merchants = [
    // Shopping -> E-commerce
    MerchantDefinition(
      id: 'amazon',
      name: 'Amazon',
      categoryId: 'shopping',
      subcategoryId: 'ecommerce',
      brandKey: 'amazon',
      iconAsset: 'assets/brands/amazon.png',
      keywords: ['amazon', 'amazon.in', 'amazon shopping', 'prime shopping'],
    ),
    MerchantDefinition(
      id: 'flipkart',
      name: 'Flipkart',
      categoryId: 'shopping',
      subcategoryId: 'ecommerce',
      brandKey: 'flipkart',
      iconAsset: 'assets/brands/flipkart.png',
      keywords: ['flipkart'],
    ),
    MerchantDefinition(
      id: 'myntra',
      name: 'Myntra',
      categoryId: 'shopping',
      subcategoryId: 'ecommerce',
      brandKey: 'myntra',
      iconAsset: 'assets/brands/myntra.png',
      keywords: ['myntra'],
    ),
    MerchantDefinition(
      id: 'meesho',
      name: 'Meesho',
      categoryId: 'shopping',
      subcategoryId: 'ecommerce',
      brandKey: 'meesho',
      iconAsset: 'assets/brands/meesho.png',
      keywords: ['meesho'],
    ),
    MerchantDefinition(
      id: 'ajio',
      name: 'AJIO',
      categoryId: 'shopping',
      subcategoryId: 'ecommerce',
      brandKey: 'ajio',
      iconAsset: 'assets/brands/ajio.png',
      keywords: ['ajio'],
    ),
    MerchantDefinition(
      id: 'savana',
      name: 'Savana',
      categoryId: 'shopping',
      subcategoryId: 'ecommerce',
      brandKey: 'savana',
      iconAsset: 'assets/brands/savana.png',
      keywords: ['savana'],
    ),
    MerchantDefinition(
      id: 'nykaa',
      name: 'Nykaa',
      categoryId: 'shopping',
      subcategoryId: 'ecommerce',
      brandKey: 'nykaa',
      iconAsset: 'assets/brands/nykaa.png',
      keywords: ['nykaa'],
    ),
    MerchantDefinition(
      id: 'tatacliq',
      name: 'Tata CLiQ',
      categoryId: 'shopping',
      subcategoryId: 'ecommerce',
      brandKey: 'tatacliq',
      iconAsset: 'assets/brands/tatacliq.png',
      keywords: ['tata cliq', 'tatacliq'],
    ),

    // Food & Dining -> Restaurants / Food Delivery / Fast Food / Coffee
    MerchantDefinition(
      id: 'swiggy',
      name: 'Swiggy',
      categoryId: 'food_dining',
      subcategoryId: 'food_delivery',
      brandKey: 'swiggy',
      iconAsset: 'assets/brands/swiggy.png',
      keywords: ['swiggy', 'swiggy food', 'swiggy order'],
    ),
    MerchantDefinition(
      id: 'zomato',
      name: 'Zomato',
      categoryId: 'food_dining',
      subcategoryId: 'food_delivery',
      brandKey: 'zomato',
      iconAsset: 'assets/brands/zomato.png',
      keywords: ['zomato'],
    ),
    MerchantDefinition(
      id: 'starbucks',
      name: 'Starbucks',
      categoryId: 'food_dining',
      subcategoryId: 'coffee',
      brandKey: 'starbucks',
      iconAsset: 'assets/brands/starbucks.png',
      keywords: ['starbucks', 'starbuck'],
    ),
    MerchantDefinition(
      id: 'mcdonalds',
      name: "McDonald's",
      categoryId: 'food_dining',
      subcategoryId: 'fast_food',
      brandKey: 'mcdonalds',
      iconAsset: 'assets/brands/mcdonalds.png',
      keywords: ['mcdonald', 'mcd', "mcdonald's"],
    ),
    MerchantDefinition(
      id: 'kfc',
      name: 'KFC',
      categoryId: 'food_dining',
      subcategoryId: 'fast_food',
      brandKey: 'kfc',
      iconAsset: 'assets/brands/kfc.png',
      keywords: ['kfc'],
    ),
    MerchantDefinition(
      id: 'dominos',
      name: "Domino's",
      categoryId: 'food_dining',
      subcategoryId: 'fast_food',
      brandKey: 'dominos',
      iconAsset: 'assets/brands/dominos.png',
      keywords: ['domino', "domino's", 'dominos pizza'],
    ),
    MerchantDefinition(
      id: 'pizzahut',
      name: 'Pizza Hut',
      categoryId: 'food_dining',
      subcategoryId: 'fast_food',
      brandKey: 'pizzahut',
      iconAsset: 'assets/brands/pizzahut.png',
      keywords: ['pizza hut', 'pizzahut'],
    ),
    MerchantDefinition(
      id: 'burgerking',
      name: 'Burger King',
      categoryId: 'food_dining',
      subcategoryId: 'fast_food',
      brandKey: 'burgerking',
      iconAsset: 'assets/brands/burgerking.png',
      keywords: ['burger king', 'burgerking'],
    ),

    // Groceries -> Quick Commerce / Supermarket
    MerchantDefinition(
      id: 'blinkit',
      name: 'Blinkit',
      categoryId: 'groceries',
      subcategoryId: 'quick_commerce',
      brandKey: 'blinkit',
      iconAsset: 'assets/brands/blinkit.png',
      keywords: ['blinkit', 'blink it'],
    ),
    MerchantDefinition(
      id: 'zepto',
      name: 'Zepto',
      categoryId: 'groceries',
      subcategoryId: 'quick_commerce',
      brandKey: 'zepto',
      iconAsset: 'assets/brands/zepto.png',
      keywords: ['zepto'],
    ),
    MerchantDefinition(
      id: 'instamart',
      name: 'Instamart',
      categoryId: 'groceries',
      subcategoryId: 'quick_commerce',
      brandKey: 'instamart',
      iconAsset: 'assets/brands/instamart.png',
      keywords: ['instamart', 'swiggy instamart'],
    ),
    MerchantDefinition(
      id: 'bigbasket',
      name: 'BigBasket',
      categoryId: 'groceries',
      subcategoryId: 'quick_commerce',
      brandKey: 'bigbasket',
      iconAsset: 'assets/brands/bigbasket.png',
      keywords: ['bigbasket', 'big basket'],
    ),
    MerchantDefinition(
      id: 'jiomart',
      name: 'JioMart',
      categoryId: 'groceries',
      subcategoryId: 'supermarket',
      brandKey: 'jiomart',
      iconAsset: 'assets/brands/jiomart.png',
      keywords: ['jiomart', 'jio mart'],
    ),
    MerchantDefinition(
      id: 'dmart',
      name: 'DMart',
      categoryId: 'groceries',
      subcategoryId: 'supermarket',
      brandKey: 'dmart',
      iconAsset: 'assets/brands/dmart.png',
      keywords: ['dmart', 'd mart'],
    ),

    // Transport -> Cab
    MerchantDefinition(
      id: 'uber',
      name: 'Uber',
      categoryId: 'transport',
      subcategoryId: 'cab',
      brandKey: 'uber',
      iconAsset: 'assets/brands/uber.png',
      keywords: ['uber', 'uber ride', 'uber trip'],
    ),
    MerchantDefinition(
      id: 'ola',
      name: 'Ola',
      categoryId: 'transport',
      subcategoryId: 'cab',
      brandKey: 'ola',
      iconAsset: 'assets/brands/ola.png',
      keywords: ['ola', 'ola ride'],
    ),
    MerchantDefinition(
      id: 'rapido',
      name: 'Rapido',
      categoryId: 'transport',
      subcategoryId: 'cab',
      brandKey: 'rapido',
      iconAsset: 'assets/brands/rapido.png',
      keywords: ['rapido'],
    ),

    // Bills -> Mobile / Internet
    MerchantDefinition(
      id: 'airtel',
      name: 'Airtel',
      categoryId: 'bills_recharge',
      subcategoryId: 'mobile',
      brandKey: 'airtel',
      iconAsset: 'assets/brands/airtel.png',
      keywords: ['airtel', 'airtel mobile', 'airtel recharge', 'airtel broadband', 'airtel xstream'],
    ),
    MerchantDefinition(
      id: 'jio',
      name: 'Jio',
      categoryId: 'bills_recharge',
      subcategoryId: 'mobile',
      brandKey: 'jio',
      iconAsset: 'assets/brands/jio.png',
      keywords: ['jio', 'jio mobile', 'jiofiber', 'jio fiber', 'jio recharge'],
    ),
    MerchantDefinition(
      id: 'vi',
      name: 'Vi',
      categoryId: 'bills_recharge',
      subcategoryId: 'mobile',
      brandKey: 'vi',
      iconAsset: 'assets/brands/vi.png',
      keywords: ['vi', 'vi mobile', 'vi recharge', 'vodafone', 'idea'],
    ),
    MerchantDefinition(
      id: 'bsnl',
      name: 'BSNL',
      categoryId: 'bills_recharge',
      subcategoryId: 'mobile',
      brandKey: 'bsnl',
      iconAsset: 'assets/brands/bsnl.png',
      keywords: ['bsnl'],
    ),
    MerchantDefinition(
      id: 'tataplay',
      name: 'Tata Play',
      categoryId: 'bills_recharge',
      subcategoryId: 'dth',
      brandKey: 'tataplay',
      iconAsset: 'assets/brands/tataplay.png',
      keywords: ['tata play', 'tataplay', 'tata sky'],
    ),

    // Entertainment -> Streaming
    MerchantDefinition(
      id: 'netflix',
      name: 'Netflix',
      categoryId: 'entertainment',
      subcategoryId: 'streaming',
      brandKey: 'netflix',
      iconAsset: 'assets/brands/netflix.png',
      keywords: ['netflix', 'netflix premium'],
    ),
    MerchantDefinition(
      id: 'spotify',
      name: 'Spotify',
      categoryId: 'entertainment',
      subcategoryId: 'music',
      brandKey: 'spotify',
      iconAsset: 'assets/brands/spotify.png',
      keywords: ['spotify'],
    ),
    MerchantDefinition(
      id: 'youtube_premium',
      name: 'YouTube Premium',
      categoryId: 'entertainment',
      subcategoryId: 'streaming',
      brandKey: 'youtube_premium',
      iconAsset: 'assets/brands/youtube.png',
      keywords: ['youtube', 'youtube premium'],
    ),
    MerchantDefinition(
      id: 'amazon_prime',
      name: 'Amazon Prime',
      categoryId: 'entertainment',
      subcategoryId: 'streaming',
      brandKey: 'amazon_prime',
      iconAsset: 'assets/brands/amazon_prime.png',
      keywords: ['prime video', 'amazon prime'],
    ),
    MerchantDefinition(
      id: 'disney_hotstar',
      name: 'JioHotstar',
      categoryId: 'entertainment',
      subcategoryId: 'streaming',
      brandKey: 'disney_hotstar',
      iconAsset: 'assets/brands/hotstar.png',
      keywords: ['hotstar', 'disney', 'jiohotstar'],
    ),
    MerchantDefinition(
      id: 'sony_liv',
      name: 'Sony LIV',
      categoryId: 'entertainment',
      subcategoryId: 'streaming',
      brandKey: 'sony_liv',
      iconAsset: 'assets/brands/sonyliv.png',
      keywords: ['sony liv', 'sonyliv'],
    ),
    MerchantDefinition(
      id: 'zee5',
      name: 'ZEE5',
      categoryId: 'entertainment',
      subcategoryId: 'streaming',
      brandKey: 'zee5',
      iconAsset: 'assets/brands/zee5.png',
      keywords: ['zee5'],
    ),

    // Payments -> Banking / Finance / ATM
    MerchantDefinition(
      id: 'phonepe',
      name: 'PhonePe',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'phonepe',
      iconAsset: 'assets/brands/phonepe.png',
      keywords: ['phonepe'],
    ),
    MerchantDefinition(
      id: 'gpay',
      name: 'Google Pay',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'gpay',
      iconAsset: 'assets/brands/gpay.png',
      keywords: ['gpay', 'google pay'],
    ),
    MerchantDefinition(
      id: 'paytm',
      name: 'Paytm',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'paytm',
      iconAsset: 'assets/brands/paytm.png',
      keywords: ['paytm'],
    ),
    MerchantDefinition(
      id: 'cred',
      name: 'CRED',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'cred',
      iconAsset: 'assets/brands/cred.png',
      keywords: ['cred'],
    ),

    // Banks -> Banking & Finance
    MerchantDefinition(
      id: 'hdfc_bank',
      name: 'HDFC Bank',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'hdfc_bank',
      iconAsset: 'assets/brands/hdfc.png',
      keywords: ['hdfc'],
    ),
    MerchantDefinition(
      id: 'sbi',
      name: 'SBI',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'sbi',
      iconAsset: 'assets/brands/sbi.png',
      keywords: ['sbi', 'state bank'],
    ),
    MerchantDefinition(
      id: 'icici_bank',
      name: 'ICICI Bank',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'icici_bank',
      iconAsset: 'assets/brands/icici.png',
      keywords: ['icici'],
    ),
    MerchantDefinition(
      id: 'axis_bank',
      name: 'Axis Bank',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'axis_bank',
      iconAsset: 'assets/brands/axis.png',
      keywords: ['axis'],
    ),
    MerchantDefinition(
      id: 'kotak_bank',
      name: 'Kotak Bank',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'kotak_bank',
      iconAsset: 'assets/brands/kotak.png',
      keywords: ['kotak'],
    ),
    MerchantDefinition(
      id: 'idfc_bank',
      name: 'IDFC FIRST Bank',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'idfc_bank',
      iconAsset: 'assets/brands/idfc.png',
      keywords: ['idfc'],
    ),
    MerchantDefinition(
      id: 'yes_bank',
      name: 'Yes Bank',
      categoryId: 'banking_finance',
      subcategoryId: 'credit_card',
      brandKey: 'yes_bank',
      iconAsset: 'assets/brands/yes.png',
      keywords: ['yes bank', 'yesbank'],
    ),
  ];

  static MerchantDefinition? detectMerchant(String title) {
    final clean = title.trim().toLowerCase();

    // Check specific priority compound cases first
    if (clean.contains('amazon prime') || clean.contains('prime video') || clean.contains('prime subscription')) {
      return merchants.firstWhere((m) => m.id == 'amazon_prime');
    }
    if (clean.contains('amazon fresh')) {
      return merchants.firstWhere((m) => m.id == 'amazon_fresh', orElse: () => merchants.firstWhere((m) => m.id == 'amazon'));
    }

    for (var m in merchants) {
      for (var kw in m.keywords) {
        if (clean.contains(kw)) {
          return m;
        }
      }
    }
    return null;
  }
}
