import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/song/mini_player.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/miscs/expandable_html.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/components/song/play_or_pause_button.dart';

class ArtistPage extends StatefulWidget {
  final String artistAlias;
  static const primaryColor = Color.fromARGB(255, 57, 133, 255);
  static const gradientColors = [
    Color.fromARGB(255, 57, 133, 255),
    Color.fromARGB(255, 41, 98, 255),
  ];

  const ArtistPage({super.key, required this.artistAlias});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> with TickerProviderStateMixin {
  late Future<ArtistModel?> _artistFuture;

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

          log('songsOfArtist: ${songsOfArtist[0].runtimeType}');
          final albumsOfArtist =
              (artist.toJson()['artist']['sections'][2]['items'] as List)
                  .map((e) => PlaylistModel.fromJson<ArtistModel>(e))
                  .cast<Future<PlaylistModel>>()
                  .toList();

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    toolbarHeight: 300,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _artistHeader(artist),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          MediaQuery.of(context).size.height -
                          300, // or a fixed height if you prefer
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _ArtistInfo(artist: artist),
                              Divider(
                                color: Theme.of(context).dividerColor,
                                thickness: 0.5,
                              ),
                              defaultFutureBuilder(
                                future: Future.wait(songsOfArtist),
                                onData:
                                    (context, data) => _SongsOfArtist(
                                      songs:
                                          data
                                              .map((e) => e as SongModel)
                                              .toList(),
                                    ),
                              ),
                              Divider(
                                color: Theme.of(context).dividerColor,
                                thickness: 0.5,
                              ),
                              defaultFutureBuilder(
                                future: Future.wait(albumsOfArtist),
                                onData:
                                    (context, data) => _AlbumsOfArtist(
                                      albums:
                                          data
                                              .map((e) => e as PlaylistModel)
                                              .toList(),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(bottom: 5, left: 0, right: 0, child: MiniPlayer()),
            ],
          );
        },
      ),
    );
  }

  Widget _artistHeader(ArtistModel artist) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
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
                      Theme.of(context).scaffoldBackgroundColor.withAlpha(180),
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
          bottom: 40,

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
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Phát nhạc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ArtistPage.primaryColor,

                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  _FollowButton(artistId: artist.id),
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
  late bool _isFollowing;

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
            icon: Icon(data ? Icons.check : Icons.add),
            label: Text(data ? 'Đã theo dõi' : 'Theo dõi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() {
                _isFollowing = !_isFollowing;
                unawaited(
                  getIt<SupabaseApi>().artists.toggleFollowArtist(
                    widget.artistId,
                  ),
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
    log('artist.biography: ${artist.biography}, ${artist.biography?.length}');

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
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: ArtistPage.primaryColor,
                side: const BorderSide(
                  color: ArtistPage.primaryColor,
                  width: 1,
                ),
              ),
              icon: const Icon(Icons.list_rounded),
              label: const Text('Xem tất cả'),
              onPressed: () {},
            ),
          ],
        ),
        SizedBox(
          height: 270,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final song = songs[index];
              return _SongListTile(song: song);
            },
            itemCount: songs.length > 3 ? 3 : songs.length,
          ),
        ),
      ],
    );
  }
}

class _SongListTile extends StatelessWidget {
  final SongModel song;
  const _SongListTile({required this.song});

  @override
  Widget build(BuildContext context) {
    final playerCubit = getIt<SongPlayerCubit>();

    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      bloc: playerCubit,
      builder: (context, state) {
        final isPlaying =
            state is SongPlayerLoaded &&
            state.currentSong.id == song.id &&
            playerCubit.isPlaying;

        return SizedBox(
          height: 80,
          child: Card(
            elevation: isPlaying ? 8 : 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side:
                  isPlaying
                      ? BorderSide(color: ArtistPage.primaryColor, width: 2)
                      : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await playerCubit.loadAndPlay(
                  context,
                  song,
                  songList: List<SongModel>.from([song]),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient:
                      isPlaying
                          ? LinearGradient(
                            colors: [
                              ArtistPage.primaryColor.withOpacity(0.1),
                              ArtistPage.primaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                          : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Hero(
                            tag: 'song_${song.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: song.thumbnailUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
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
                                      child: const Icon(Icons.music_note),
                                    ),
                              ),
                            ),
                          ),
                          if (isPlaying)
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              song.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isPlaying
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                color:
                                    isPlaying ? ArtistPage.primaryColor : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artistsNames,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      PlayOrPauseButton(
                        song: song,
                        color:
                            isPlaying
                                ? ArtistPage.primaryColor
                                : Colors.grey[600] ?? Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
      child: InkWell(
        onTap: () {},
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
                        onTap: () {},
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
