import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/artist/album_list_tile.dart';
import 'package:memecloud/components/artist/song_list_tile.dart';
import 'package:memecloud/components/common/confirmation_dialog.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
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

class ArtistPage extends StatefulWidget {
  final String artistAlias;

  const ArtistPage({super.key, required this.artistAlias});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> with TickerProviderStateMixin {
  late Future<ArtistModel?> _artistFuture;
  late List<SongModel> songs;
  late List<PlaylistModel> albums;
  late List<PlaylistModel> playlists;

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

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 270,
                    collapsedHeight: 90,
                    floating: false,
                    snap: false,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: _artistHeader(artist),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            _ArtistInfo(artist: artist),
                            Divider(
                              color: Theme.of(context).dividerColor,
                              thickness: 0.5,
                            ),

                            if (songs.isEmpty)
                              const SizedBox.shrink(
                                child: Text('Chưa có bài hát nào.'),
                              )
                            else
                              _SongsOfArtist(songs: songs),

                            Divider(
                              color: Theme.of(context).dividerColor,
                              thickness: 0.5,
                            ),

                            if (playlists.isEmpty)
                              const SizedBox.shrink(
                                child: Text('Chưa có album nào.'),
                              )
                            else
                              _AlbumsOfArtist(
                                title: 'Playlist',
                                albums: playlists,
                              ),
                            Divider(
                              color: Theme.of(context).dividerColor,
                              thickness: 0.5,
                            ),

                            if (albums.isEmpty)
                              const SizedBox.shrink(
                                child: Text('Chưa có album nào.'),
                              )
                            else
                              _AlbumsOfArtist(title: 'Albums', albums: albums),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: 72)),
                ],
              ),
              MiniPlayer(floating: true),
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
        if (artist.realname != null) ...[
          Text(
            'Tên thật',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${artist.realname}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
        if (artist.biography != null) ...[
          Divider(color: Theme.of(context).dividerColor, thickness: 0.5),
          const SizedBox(height: 4),
          Text(
            'Tiểu sử',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
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

class _SongsOfArtist extends StatelessWidget {
  final List<SongModel> songs;

  const _SongsOfArtist({required this.songs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bài hát',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 100 * math.min(songs.length.toDouble(), 5),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongListTile(song: song);
            },
            itemCount: songs.length > 5 ? 5 : songs.length,
          ),
        ),
        if (songs.length > 5)
          TextButton.icon(
            onPressed:
                () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListSongPage(songs: songs),
                    ),
                  ),
                },
            label: Text("Xem thêm"),
            icon: Icon(Icons.arrow_right),
          ),
      ],
    );
  }
}

class _AlbumsOfArtist extends StatelessWidget {
  final String title;
  final List<PlaylistModel> albums;

  const _AlbumsOfArtist({required this.title, required this.albums});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: SizedBox(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final album = albums[index];
                return AlbumListTile(album: album);
              },
              itemCount: albums.length > 4 ? 4 : albums.length,
            ),
          ),
        ),
        if (albums.length > 4)
          TextButton.icon(
            onPressed:
                () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumArtistPage(albums: albums),
                    ),
                  ),
                },
            label: Text("Xem thêm"),
            icon: Icon(Icons.arrow_right),
          ),
      ],
    );
  }
}
