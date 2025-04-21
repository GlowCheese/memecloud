import 'package:go_router/go_router.dart';
import 'package:memecloud/apis/supabase/auth.dart';
import 'package:memecloud/components/gradient_background.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/pages/404.dart';
import 'package:memecloud/pages/auth/signin_page.dart';
import 'package:memecloud/pages/auth/signup_page.dart';
import 'package:memecloud/pages/auth/start_page.dart';
import 'package:memecloud/pages/home/home_page.dart';
import 'package:memecloud/pages/search/search_page.dart';
import 'package:memecloud/pages/song/song_page.dart';

GoRouter? router;

GoRouter getRouter() {
  router ??= GoRouter(
    initialLocation:
        getIt<SupabaseAuthApi>().currentSession() != null
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
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(path: '/play_music', builder: (context, state) => SongPage()),
        ],
      ),
      GoRoute(path: '/startview', builder: (context, state) => StartPage()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpView()),
      GoRoute(path: '/login', builder: (context, state) => SignInPage()),
    ],
  );
  return router!;
}
