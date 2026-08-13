import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectionChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  bool _mockConnection = true;

  void setConnectionMock(bool connected) {
    _mockConnection = connected;
  }

  @override
  Future<bool> get isConnected async => _mockConnection;

  @override
  Stream<bool> get onConnectionChanged => Stream.value(_mockConnection);
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});
