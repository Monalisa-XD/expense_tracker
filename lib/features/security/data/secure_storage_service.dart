import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyPinHash = 'secure_pin_hash';
  static const String _keyPinSalt = 'secure_pin_salt';

  Future<void> savePin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _storage.write(key: _keyPinHash, value: hash);
    await _storage.write(key: _keyPinSalt, value: salt);
  }

  Future<bool> verifyPin(String pin) async {
    final hash = await _storage.read(key: _keyPinHash);
    final salt = await _storage.read(key: _keyPinSalt);
    if (hash == null || salt == null) return false;
    return _hashPin(pin, salt) == hash;
  }

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPinHash);
    return hash != null;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinSalt);
  }

  String _generateSalt() {
    final rnd = Random.secure();
    final values = List<int>.generate(16, (i) => rnd.nextInt(256));
    return base64Url.encode(values);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    return sha256.convert(bytes).toString();
  }
}
