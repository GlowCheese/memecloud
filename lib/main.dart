import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memecloud/demo.dart';
import 'package:memecloud/components/gradient_background.dart';
import 'package:memecloud/pages/404.dart';
import 'package:memecloud/pages/auth/signin_page.dart';
import 'package:memecloud/pages/auth/signup_page.dart';
import 'package:memecloud/pages/home/home_page.dart';
import 'package:memecloud/pages/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:memecloud/pages/song/song_page.dart';
import 'package:memecloud/pages/auth/start_page.dart';
import 'package:memecloud/core/getit.dart' show setupLocator;
import 'package:memecloud/core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GoRouter _router = GoRouter(
  initialLocation:
      Supabase.instance.client.auth.currentSession != null
          ? '/home'
          : '/startview',
  errorBuilder: (context, state) {
    return pageWithGradientBackground(
      context,
      state,
      PageNotFound(routePath: state.uri.toString()),
    );
  },
  routes: [
    ShellRoute(
      builder: pageWithGradientBackground,
      routes: [
        GoRoute(
          path: '/404',
          builder: (context, state) => PageNotFound(routePath: '/404'),
        ),
        GoRoute(path: '/home', builder: (context, state) => HomePage()),
        GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
        GoRoute(path: '/play_music', builder: (context, state) => SongPage())
      ],
    ),
    GoRoute(path: '/startview', builder: (context, state) => StartPage()),
    GoRoute(path: '/signup', builder: (context, state) => SignUpView()),
    GoRoute(path: '/login', builder: (context, state) => SignInPage()),
  ],
);

void main() async {
  await dotenv.load(fileName: ".env");
  await setupLocator();

  // ignore: dead_code
  if (false) {
    await demo();
  }
  // ignore: dead_code
  else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: MaterialTheme.lightScheme(),
      ),
      dark: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: MaterialTheme.darkScheme(),
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          routerConfig: _router,
        );
      },
    );
  }
}
