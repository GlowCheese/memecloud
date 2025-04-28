import 'package:go_router/go_router.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/pages/404.dart';
import 'package:memecloud/pages/auth/signin_page.dart';
import 'package:memecloud/pages/auth/signup_page.dart';
import 'package:memecloud/pages/dashboard/dashboard_page.dart';
import 'package:memecloud/pages/experiment/e00.dart';
import 'package:memecloud/pages/experiment/experiment_page.dart';
import 'package:memecloud/pages/profile/profile_page.dart';
import 'package:memecloud/pages/song/song_page.dart';
import 'package:memecloud/routes/builders.dart';

GoRouter? router;

GoRouter getRouter() {
  router ??= GoRouter(
    initialLocation:
    // '/experiment',
    getIt<ApiKit>().currentSession() != null
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
          GoRoute(path: '/song_play', builder: (context, state) => SongPage()),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardPage(),
          ),
          GoRoute(
            path: '/experiment',
            builder: (context, state) => E00(body: ExperimentPage()),
          ),
        ],
      ),
      GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
      GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
    ],
  );
  return router!;
}
