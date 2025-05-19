import 'package:go_router/go_router.dart';
import 'package:memecloud/pages/404/404.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/pages/404/404.dart';
import 'package:memecloud/pages/artist/artist_page.dart';
import 'package:memecloud/pages/playlist/playlist_page.dart';
import 'package:memecloud/pages/song/song_page.dart';
import 'package:memecloud/pages/auth/signin_page.dart';
import 'package:memecloud/pages/auth/signup_page.dart';
import 'package:memecloud/components/song/song_lyric.dart';
import 'package:memecloud/pages/profile/profile_page.dart';
import 'package:memecloud/pages/dashboard/dashboard_page.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/utils/transition.dart';


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
        path: '/playlist_page',
        pageBuilder: (context, state) {
          final playlistId = state.extra as String;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PlaylistPage(playlistId: playlistId),
            transitionsBuilder: PageTransitions.slideTransition,
          );
        },
      ),
      GoRoute(
        path: '/artist_page',
        pageBuilder: (context, state) {
          final artistAlias = state.extra as String;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ArtistPage(artistAlias: artistAlias),
            transitionsBuilder: PageTransitions.slideTransition,
          );
        },

      ),
    ],
  );
  return router!;
}
