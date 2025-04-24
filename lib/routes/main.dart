import 'package:go_router/go_router.dart';
import 'package:memecloud/apis/supabase/auth.dart';
import 'package:memecloud/components/gradient_background.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/pages/404.dart';
import 'package:memecloud/pages/auth/signin_page.dart';
import 'package:memecloud/pages/auth/signup_page.dart';
// import 'package:memecloud/pages/auth/start_page.dart';
import 'package:memecloud/pages/dashboard/dashboard_page.dart';
import 'package:memecloud/pages/dashboard/profile_page.dart';
import 'package:memecloud/pages/dashboard/song/song_page.dart';

GoRouter? router;

GoRouter getRouter() {
  router ??= GoRouter(
    initialLocation:
        getIt<SupabaseAuthApi>().currentSession() != null
            ? '/dashboard'
            : '/signin',
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
          GoRoute(
            path: '/song_play',
            builder: (context, state) => SongPage()
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardPage()
          )
        ],
      ),
      // GoRoute(path: '/startview', builder: (context, state) => StartPage()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
      GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage())
    ],
  );
  return router!;
}
