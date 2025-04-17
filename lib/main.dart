import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memecloud/data/models/song/song_dto.dart';
import 'package:memecloud/presentation/view/404.dart';
import 'package:memecloud/presentation/view/auth/log_in_view.dart';
import 'package:memecloud/presentation/view/auth/sign_up_view.dart';
import 'package:memecloud/presentation/view/home/home_view.dart';
// import 'package:memecloud/presentation/view/play_music_view.dart';
import 'package:memecloud/presentation/view/search_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:memecloud/presentation/view/song_player/song_player_view.dart';
import 'package:memecloud/presentation/view/start_view.dart';
import 'package:memecloud/builders.dart';
import 'package:memecloud/service_locator.dart' show initDependencies;
import 'package:memecloud/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Page _transitionPage(Widget child, GoRouterState state) {
//   return CustomTransitionPage(
//     key: state.pageKey,
//     child: child,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

//       final scale = Tween<double>(begin: 0.96, end: 1.0).animate(fade);

//       return FadeTransition(
//         opacity: fade,
//         child: ScaleTransition(scale: scale, child: child),
//       );
//     },
//   );
// }

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
        GoRoute(path: '/home', builder: (context, state) => HomeView()),
        GoRoute(path: '/search', builder: (context, state) => const SearchView()),
        GoRoute(path: '/play_music', builder: (context, state) {
          final song = state.extra as SongDto;
          return SongPlayerView(song: song);
        })
      ],
    ),
    GoRoute(path: '/startview', builder: (context, state) => StartView()),
    GoRoute(path: '/signup', builder: (context, state) => SignUpView()),
    GoRoute(path: '/login', builder: (context, state) => LogInView()),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'].toString(),
    anonKey: dotenv.env['SUPABASE_ANON_KEY'].toString(),
    authOptions: FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );

  await initDependencies();

  runApp(const MyApp());
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
