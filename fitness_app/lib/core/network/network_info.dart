/// Network connectivity check abstraction.
///
/// [NetworkInfo] is an interface used by repositories to gate remote calls
/// behind a connectivity check before hitting Firestore or an API. This keeps
/// network logic testable and out of the data-source layer.
///
/// [NetworkInfoImpl] checks connectivity by doing a DNS lookup for
/// `google.com` — if the lookup fails the device is considered offline.
library;

import 'dart:io';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}