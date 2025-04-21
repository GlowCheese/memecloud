import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';


Future<void> createDioWithPersistentCookies(GetIt serviceLocator) async {
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

  serviceLocator.registerSingleton<Dio>(dio);
  serviceLocator.registerSingleton<CookieJar>(cookieJar);
}