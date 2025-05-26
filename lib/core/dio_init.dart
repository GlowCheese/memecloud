import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

void dioInterceptorSetCustomCookie(
  Dio dio,
  CookieJar cookieJar,
  String cookie,
) {
  dio.interceptors.insert(
    0,
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final uri = options.uri;

        final cookies = await cookieJar.loadForRequest(uri);
        final hasAuthCookie = cookies.any((c) => c.name == 'za_oauth_v4');

        if (!hasAuthCookie) options.headers['Cookie'] = cookie;

        return handler.next(options);
      },
    ),
  );
}

void dioInterceptorUpdateCookieOnSet(Dio dio, ApiKit apiKit) {
  dio.interceptors.insert(
    0,
    InterceptorsWrapper(
      onResponse: (response, handler) {
        final setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
          final cookies = setCookieHeader;
          unawaited(apiKit.updateZingCookie(cookies));
        }
        return handler.next(response);
      },
    ),
  );
}

Future<(Dio, CookieJar)> createDioWithPersistentCookies() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage('${appDocDir.path}/.cookies/'),
  );

  final dio = Dio();
  dio.options.headers.addAll({
    'User-Agent': 'python-requests/2.32.3',
    'Accept-Encoding': 'gzip, deflate',
    'Accept': '*/*',
    'Connection': 'keep-alive',
  });

  dio.interceptors.add(CookieManager(cookieJar));
  return (dio, cookieJar);
}
