import 'package:go_router/go_router.dart';
import 'package:memecloud/pages/404/404.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/pages/song/song_page.dart';
import 'package:memecloud/pages/auth/signin_page.dart';
import 'package:memecloud/pages/auth/signup_page.dart';
import 'package:memecloud/components/song/song_lyric.dart';
import 'package:memecloud/pages/profile/profile_page.dart';
import 'package:memecloud/components/grad_background.dart';
import 'package:memecloud/pages/dashboard/dashboard_page.dart';
import 'package:memecloud/pages/playlist/play_list.dart';

GoRouter? router;

GoRouter getRouter() {
  router ??= GoRouter(
    initialLocation:
        getIt<ApiKit>().currentSession() != null ? '/dashboard' : '/signin',
    errorBuilder: (context, state) {
      return GradBackground(
        child: PageNotFound(routePath: state.uri.toString()),
      );
    },
    routes: [
      GoRoute(
        path: '/404',
        builder: (context, state) => PageNotFound(routePath: '/404'),
      ),
      GoRoute(path: '/dashboard', builder: (context, state) => DashboardPage()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
      GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
      GoRoute(path: '/song_page', builder: (context, state) => SongPage()),
      GoRoute(
        path: '/song_lyric',
        builder: (context, state) => SongLyricPage(),
      ),
      GoRoute(
        path: '/playlist',
        builder:
            (context, state) => PlaylistScreen(
              playlistId: state.uri.queryParameters['playlistId'] ?? '',
            ),
      ),
    ],
  );
  return router!;
}
