import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/artist/song_list_tile.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/song/mini_player.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/miscs/expandable_html.dart';

import 'package:memecloud/pages/artist/song_artist_page.dart';

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

  @override
  void initState() {
    super.initState();
    _artistFuture = getIt<ApiKit>().getArtistInfo(widget.artistAlias);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ArtistModel?>(
        future: _artistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingArtist();
          }
          if (snapshot.hasError) {
            return Center(child: SelectableText('Error: ${snapshot.error}'));
          }
          final artist = snapshot.data;
          if (artist == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin nghệ sĩ'),
            );
          }

          final List<Future<SongModel>> songsOfArtist =
              (artist.toJson()['artist']['sections'][0]['items'] as List)
                  .map((e) => SongModel.fromJson<SupabaseApi>(e))
                  .cast<Future<SongModel>>()
                  .toList();

          final albumsOfArtist =
              (artist.toJson()['artist']['sections'][2]['items'] as List)
                  .map((e) => PlaylistModel.fromJson<ArtistModel>(e))
                  .cast<Future<PlaylistModel>>()
                  .toList();

          return Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Stack(
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
                              defaultFutureBuilder(
                                future: Future.wait(songsOfArtist),
                                onData: (context, data) {
                                  songs =
                                      data.map((e) => e as SongModel).toList();
                                  if (songs.isEmpty) {
                                    return const SizedBox.shrink(
                                      child: Text('Chưa có bài hát nào.'),
                                    );
                                  }
                                  return _SongsOfArtist(songs: songs);
                                },
                              ),
                              Divider(
                                color: Theme.of(context).dividerColor,
                                thickness: 0.5,
                              ),
                              defaultFutureBuilder(
                                future: Future.wait(albumsOfArtist),
                                onData: (context, data) {
                                  albums =
                                      data
                                          .map((e) => e as PlaylistModel)
                                          .toList();
                                  if (albums.isEmpty) {
                                    return const SizedBox.shrink(
                                      child: Text('Chưa có album nào.'),
                                    );
                                  }
                                  return _AlbumsOfArtist(albums: albums);
                                },
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
                MiniPlayer(),
              ],
            ),
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
                      Theme.of(context).colorScheme.primaryContainer,
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
                        future: getIt<SupabaseApi>().artists
                            .getArtistFollowersCount(artist.id),
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
                      _FollowButton(artistId: artist.id),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (playerCubit.shuffleMode) {
                            await playerCubit.toggleShuffleMode();
                          }
                          await playerCubit.loadAndPlay(
                            context,
                            songs[0],
                            songList: List<SongModel>.from(songs),
                          );
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
                          if (!playerCubit.shuffleMode) {
                            await playerCubit.toggleShuffleMode();
                          }
                          await playerCubit.loadAndPlay(
                            context,
                            songs[0],
                            songList: List<SongModel>.from(songs),
                          );
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
}

class _FollowButton extends StatefulWidget {
  final String artistId;
  const _FollowButton({required this.artistId});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  late Future<bool> _isFollowingFuture;

  @override
  void initState() {
    super.initState();
    _isFollowingFuture = getIt<SupabaseApi>().artists.isFollowingArtist(
      widget.artistId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: _isFollowingFuture,
      onData:
          (context, data) => OutlinedButton.icon(
            icon: Icon(data ? Icons.notifications : null),
            label: Text(data ? 'Đã theo dõi' : 'Theo dõi'),
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
              setState(() {
                unawaited(
                  getIt<SupabaseApi>().artists
                      .toggleFollowArtist(widget.artistId)
                      .then((_) {
                        setState(() {
                          _isFollowingFuture = getIt<SupabaseApi>().artists
                              .isFollowingArtist(widget.artistId);
                        });
                      }),
                );
              });
            },
          ),
    );
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
          height: 85 * math.min(songs.length.toDouble(), 5),
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
                      builder: (context) => SongArtistPage(songs: songs),
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
  final List<PlaylistModel> albums;

  const _AlbumsOfArtist({required this.albums});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Album',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
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
                return _AlbumCard(album: album);
              },
              itemCount: albums.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final PlaylistModel album;
  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.onSecondary,
      child: InkWell(
        onTap: () {
          //TO DO: play album
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'album_${album.id}',
                    child: CachedNetworkImage(
                      imageUrl: album.thumbnailUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.album,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),

                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // TO DO: play album
                        },
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    album.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (album.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      album.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _loadingArtist() {
  return const Center(child: CircularProgressIndicator());
}
