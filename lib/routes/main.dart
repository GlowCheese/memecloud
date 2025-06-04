import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/pages/404/404.dart';
import 'package:memecloud/pages/hub/hub_page.dart';
import 'package:memecloud/routes/transitions.dart';
import 'package:memecloud/pages/song/song_page.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/pages/auth/signin_page.dart';
import 'package:memecloud/pages/auth/signup_page.dart';
import 'package:memecloud/pages/artist/artist_page.dart';
import 'package:memecloud/components/song/song_lyric.dart';
import 'package:memecloud/pages/profile/profile_page.dart';
import 'package:memecloud/pages/song/song_history_page.dart';
import 'package:memecloud/pages/playlist/playlist_page.dart';
import 'package:memecloud/pages/dashboard/dashboard_page.dart';
import 'package:memecloud/components/miscs/grad_background.dart';

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
        builder: (context, state) => const PageNotFound(routePath: '/404'),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(path: '/signin', builder: (context, state) => const SignInPage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/song_lyric',
        builder: (context, state) => const SongLyricPage(),
      ),
      GoRoute(
        path: '/playlist_page',
        pageBuilder: (context, state) {
          if (state.extra is String) {
            final playlistId = state.extra as String;
            return CustomTransitionPage(
              key: state.pageKey,
              child: PlaylistPage(playlistId: playlistId),
              transitionsBuilder: PageTransitions.fadeTransition,
            );
          } else {
            final playlist = state.extra as PlaylistModel;
            return CustomTransitionPage(
              key: state.pageKey,
              child: PlaylistPage(playlist: playlist),
              transitionsBuilder: PageTransitions.fadeTransition,
            );
          }
        },
      ),
      GoRoute(
        path: '/artist_page',
        pageBuilder: (context, state) {
          final artistAlias = state.extra as String;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ArtistPage17(artistAlias: artistAlias),
            transitionsBuilder: PageTransitions.fadeTransition,
          );
        },
      ),
      GoRoute(
        path: '/song_page',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: SongPage(),
              transitionsBuilder: PageTransitions.fadeTransition,
            ),
      ),
      GoRoute(
        path: '/song_history_page',
        pageBuilder: (context, state) {
          final playlist = state.extra as PlaylistModel?;
          return CustomTransitionPage(
            child: ScrollableSongHistoryPage(playlist: playlist),
            transitionsBuilder: PageTransitions.fadeTransition,
          );
        },
      ),
      GoRoute(
        path: '/hub_page',
        pageBuilder: (context, state) {
          final hubId = state.extra as String;
          return CustomTransitionPage(
            child: HubPage(hubId: hubId),
            transitionsBuilder: PageTransitions.fadeTransition,
          );
        },
      ),
    ],
  );
  return router!;
}
