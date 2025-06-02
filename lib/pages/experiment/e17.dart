import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/artist/song_list_tile.dart';
import 'package:memecloud/components/common/confirmation_dialog.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/song/mini_player.dart';

import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';

import 'package:memecloud/pages/song/list_song_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/miscs/expandable/html.dart';
import 'package:memecloud/pages/artist/album_artist_page.dart';

class ArtistPage17 extends StatefulWidget {
  final String artistAlias;

  const ArtistPage17({super.key, required this.artistAlias});

  @override
  State<ArtistPage17> createState() => _ArtistPage17State();
}

class _ArtistPage17State extends State<ArtistPage17>
    with TickerProviderStateMixin {
  late Future<ArtistModel?> _artistFuture;
  late List<SongModel> songs;
  late List<PlaylistModel> albums;
  late List<PlaylistModel> playlists;
  late List<PlaylistModel> collections;
  late List<PlaylistModel> appearsIn;

  @override
  void initState() {
    super.initState();
    _artistFuture = getIt<ApiKit>().getArtistInfo(widget.artistAlias);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: defaultFutureBuilder(
        future: _artistFuture,
        onNull: (context) {
          return const Center(child: Text('Không tìm thấy thông tin nghệ sĩ'));
        },
        onData: (context, artist) {
          songs = artist!.sections![0].items.cast<SongModel>().toList();

          playlists = artist.sections![1].items.cast<PlaylistModel>().toList();

          albums = artist.sections![2].items.cast<PlaylistModel>().toList();

          collections =
              artist.sections![3].items.cast<PlaylistModel>().toList();
          appearsIn = artist.sections![4].items.cast<PlaylistModel>().toList();

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: Colors.black87,
                    automaticallyImplyLeading: false,
                    flexibleSpace: LayoutBuilder(
                      builder: (
                        BuildContext context,
                        BoxConstraints constraints,
                      ) {
                        final bool collapsed =
                            constraints.biggest.height <= kToolbarHeight + 24;
                        return FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: _artistHeader(artist),
                          title:
                              collapsed
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () => Navigator.pop(context),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          artist.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                  : null,
                          titlePadding: const EdgeInsetsDirectional.only(
                            start: 16,
                            bottom: 8,
                          ),
                        );
                      },
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            if (songs.isNotEmpty) ...[
                              _SongsSection(songs: songs),
                              const SizedBox(height: 32),
                              _buildDivider(context),
                            ],
                            if (albums.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _AlbumsSection(title: 'Albums', albums: albums),
                              const SizedBox(height: 32),
                              _buildDivider(context),
                            ],
                            if (playlists.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _AlbumsSection(
                                title: 'Playlist',
                                albums: playlists,
                              ),
                              const SizedBox(height: 32),
                              _buildDivider(context),
                            ],
                            if (collections.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _AlbumsSection(
                                title: 'Tuyển tập',
                                albums: playlists,
                              ),
                              const SizedBox(height: 32),
                              _buildDivider(context),
                            ],
                            if (appearsIn.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _AlbumsSection(
                                title: 'Xuất hiện trong',
                                albums: playlists,
                              ),
                              const SizedBox(height: 32),
                              _buildDivider(context),
                            ],
                            const SizedBox(height: 24),
                            _ArtistInfo(artist: artist),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                ],
              ),
              //MiniPlayer(floating: true),
            ],
          );
        },
      ),
    );
  }

  Widget _artistHeader(ArtistModel artist) {
    final playerCubit = getIt<SongPlayerCubit>();
    return Stack(
      fit: StackFit.loose,
      children: [
        SizedBox(
          height: 350,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: artist.thumbnailUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withAlpha(180),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,

          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
            ),
          ),
        ),

        Positioned(
          bottom: 4,

          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artist.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      defaultFutureBuilder(
                        future: getIt<ApiKit>().getArtistFollowersCount(
                          artist.id,
                        ),
                        onData: (context, data) {
                          return Text(
                            '${data.toString()} người theo dõi',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _FollowButton(artistId: artist.id),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _togglePlayShuffle(playerCubit);
                        },
                        icon: const Icon(Icons.shuffle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,

                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () async {
                          await _togglePlayNormal(playerCubit);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _togglePlayNormal(SongPlayerCubit playerCubit) async {
    if (!playerCubit.shuffleMode) {
      await playerCubit.toggleShuffleMode();
    }
    await playerCubit.loadAndPlay(
      context,
      songs[0],
      songList: List<SongModel>.from(songs),
    );
  }

  Future<void> _togglePlayShuffle(SongPlayerCubit playerCubit) async {
    if (playerCubit.shuffleMode) {
      await playerCubit.toggleShuffleMode();
    }
    if (!mounted) return;
    await playerCubit.loadAndPlay(
      context,
      songs[0],
      songList: List<SongModel>.from(songs),
    );
  }
}

Widget _buildDivider(BuildContext context) {
  return Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Theme.of(context).dividerColor.withAlpha(160),
          Colors.transparent,
        ],
      ),
    ),
  );
}

class _FollowButton extends StatefulWidget {
  final String artistId;
  const _FollowButton({required this.artistId});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool? isFollowing;

  @override
  void initState() {
    super.initState();
    unawaited(
      getIt<ApiKit>().isFollowingArtist(widget.artistId).then((isFollowing) {
        setState(() {
          this.isFollowing = isFollowing;
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFollowing == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 40,
      width: 140,
      child: OutlinedButton.icon(
        icon: Icon(
          isFollowing! ? Icons.notifications : Icons.notifications_off,
        ),
        label: Text(isFollowing! ? 'Đã theo dõi' : 'Theo dõi'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          log('toggle follow ${widget.artistId}');
          if (!isFollowing!) {
            unawaited(getIt<ApiKit>().toggleFollowArtist(widget.artistId));
            setState(() {
              isFollowing = !isFollowing!;
            });
          } else {
            _showSubmitUnfollowDialog(context);
          }
        },
      ),
    );
  }

  void _showSubmitUnfollowDialog(BuildContext context) async {
    final submitUnfollow = await ConfirmationDialog.show(
      context: context,
      title: 'Hủy theo dõi',
      message: 'Bạn có chắc chắn muốn hủy theo dõi?',
      confirmText: 'Hủy theo dõi',
      cancelText: 'Không',
    );

    if (submitUnfollow == true) {
      unawaited(getIt<ApiKit>().toggleFollowArtist(widget.artistId));
      setState(() {
        isFollowing = !isFollowing!;
      });
    }
  }
}

class _ArtistInfo extends StatelessWidget {
  final ArtistModel artist;
  const _ArtistInfo({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Về ${artist.name}',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (artist.realname != null) ...[
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                const TextSpan(text: 'Tên thật: '),
                TextSpan(
                  text: artist.realname,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
        if (artist.biography != null) ...[
          const SizedBox(height: 8),
          const Text('Tiểu sử:'),
          ExpandableHtml(
            htmlText:
                artist.biography != null && artist.biography!.isNotEmpty
                    ? artist.biography!
                    : 'Chưa có thông tin tiểu sử.',
          ),
        ],
      ],
    );
  }
}

class _SongsSection extends StatelessWidget {
  final List<SongModel> songs;
  const _SongsSection({required this.songs});

  @override
  Widget build(BuildContext context) {
    final displaySongs = songs.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displaySongs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder:
              (_, index) => SongCard(
                variant: 1,
                song: displaySongs[index],
                songList: songs,
              ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bài hát',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (songs.length > 5)
          TextButton.icon(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ListSongPage(songs: songs)),
                ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Xem tất cả'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }
}

class _AlbumsSection extends StatelessWidget {
  final String title;
  final List<PlaylistModel> albums;

  const _AlbumsSection({required this.title, required this.albums});

  @override
  Widget build(BuildContext context) {
    final displayAlbums = albums.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: displayAlbums.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 160,
                child: PlaylistCard(variant: 4, playlist: displayAlbums[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (albums.length > 4)
            TextButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlbumArtistPage(albums: albums),
                    ),
                  ),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Xem tất cả'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }
}
