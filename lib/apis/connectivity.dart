import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionLoss implements Exception {
  @override
  String toString() {
    return "Connection lost! Please try again later!";
  }
}

class ConnectivityStatus {
  static const ignoreStatusCode = 'IGNORE_1302';
  DateTime _lastConnectivityCrash = DateTime.fromMillisecondsSinceEpoch(0);

  /// Stop a method from calling API for `15` seconds
  /// if connectivity is unstable.
  void ensure() {
    if (DateTime.now().difference(_lastConnectivityCrash).inSeconds < 15) {
      throw AuthException(
        'SocketException: Lost connection',
        statusCode: ignoreStatusCode,
      );
    }
  }

  /// Use this when encountering an exception that potentially due to connectivity issue. \
  /// Throw `ConnectionLoss` if we suspect `e` originates from a `SocketException`.
  /// Otherwise do nothing.
  void reportCrash(Object e, StackTrace stackTrace) {
    if (e is! Exception) return;

    if (e.toString().contains('SocketException')) {
      if (e is! AuthException || e.statusCode != ignoreStatusCode) {
        _lastConnectivityCrash = DateTime.now();
        log('${e.runtimeType} detected: $e', stackTrace: stackTrace, level: 900);
      }
      throw ConnectionLoss();
    }
  }
}