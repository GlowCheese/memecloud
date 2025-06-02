import 'dart:developer';
import 'dart:io';

Map<String, String> convertCookieToMap(String cookieStr) {
  final parts = cookieStr.split('; ');
  final map = <String, String>{};

  for (final part in parts) {
    final kv = part.split('=');
    assert(kv.length == 2);
    map[kv[0]] = kv[1];
  }
  return map;
}

String convertCookieToString(Map<String, String> cookies) {
  return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
}

T2 convertCookieToType<T1, T2>(T1 cookie) {
  if (T1 == T2) return cookie as T2;
  if (T2 == String) {
    assert(T1 == Map<String, String>);
    return convertCookieToString(cookie as Map<String, String>) as T2;
  }
  if (T2 == Map<String, String>) {
    assert(T1 == String);
    return convertCookieToMap(cookie as String) as T2;
  }
  throw UnsupportedError('Unexpected type T2=$T2');
}

List<String>? cookieGetFirstKv(String cookieStr) {
  final kv = cookieStr.split(';').first.trim().split('=');
  if (kv.length != 2) {
    log('⚠️ Cookie format sai, bỏ qua: $cookieStr', level: 900);
    return null;
  }
  return [kv[0], kv[1]];
}

List<Cookie> parseCookies(String cookieStr, String domain) {
  final cookies = <Cookie>[];
  final parts = cookieStr.split(';');
  for (var part in parts) {
    final kv = part.trim().split('=');
    if (kv.length == 2) {
      final name = kv[0];
      final value = kv[1];
      final cookie = Cookie(name, value)
        ..domain = domain
        ..path = '/';
      cookies.add(cookie);
    }
  }
  return cookies;
}