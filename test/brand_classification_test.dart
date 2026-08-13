import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/brand_registry.dart';

void main() {
  group('BrandRegistry & Classification Tests', () {
    test('TEST 1 — Amazon shopping auto resolves to Shopping/Amazon', () {
      final detect = BrandRegistry.detectBrand('Amazon shopping');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'shopping');
      expect(detect['brandKey'], 'amazon');
      expect(detect['merchantName'], 'Amazon');
    });

    test('TEST 2 — Swiggy auto resolves to Food & Dining/Swiggy', () {
      final detect = BrandRegistry.detectBrand('swiggy food delivery');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'food_dining');
      expect(detect['brandKey'], 'swiggy');
      expect(detect['merchantName'], 'Swiggy');
    });

    test('TEST 3 — Blinkit resolves to Groceries/Blinkit', () {
      final detect = BrandRegistry.detectBrand('blinkit orders');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'groceries');
      expect(detect['brandKey'], 'blinkit');
      expect(detect['merchantName'], 'Blinkit');
    });

    test('TEST 4 — Uber resolves to Ride / Transport/Uber', () {
      final detect = BrandRegistry.detectBrand('Uber Ride');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'ride_transport');
      expect(detect['brandKey'], 'uber');
      expect(detect['merchantName'], 'Uber');
    });

    test('TEST 5 — Unknown merchant yields null for auto-detection', () {
      final detect = BrandRegistry.detectBrand('Local Tea Shop');
      expect(detect, isNull);
    });

    test('TEST 6 — SWIGGY FOOD resolves to Swiggy', () {
      final detect = BrandRegistry.detectBrand('SWIGGY FOOD');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'food_dining');
      expect(detect['brandKey'], 'swiggy');
      expect(detect['merchantName'], 'Swiggy');
    });

    test('TEST 7 — Amazon Prime resolves to Entertainment', () {
      final detect = BrandRegistry.detectBrand('Amazon Prime Video');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'entertainment');
      expect(detect['brandKey'], 'amazon_prime');
      expect(detect['merchantName'], 'Amazon Prime');
    });

    test('TEST 8 — Amazon Fresh resolves to Groceries', () {
      final detect = BrandRegistry.detectBrand('Amazon Fresh order');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'groceries');
      expect(detect['brandKey'], 'amazon_fresh');
    });

    test('TEST 9 — Airtel Broadband resolves to Bills & Recharge', () {
      final detect = BrandRegistry.detectBrand('Airtel Broadband bill');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'bills_recharge');
      expect(detect['brandKey'], 'airtel');
    });

    test('TEST 10 — Netflix Premium resolves to Entertainment', () {
      final detect = BrandRegistry.detectBrand('Netflix Premium subscription');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'entertainment');
      expect(detect['brandKey'], 'netflix');
    });

    test('TEST 11 — Zepto resolves to Groceries', () {
      final detect = BrandRegistry.detectBrand('Zepto delivery');
      expect(detect, isNotNull);
      expect(detect!['categoryId'], 'groceries');
      expect(detect['brandKey'], 'zepto');
    });
  });
}
