import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:memecloud/apis/supabase/artists.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/apis/zingmp3/requester.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/components/song/mini_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/miscs/expandable_html.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/components/song/play_or_pause_button.dart';

class ArtistPage extends StatefulWidget {
  final String artistAlias;

  const ArtistPage({super.key, required this.artistAlias});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<ArtistModel?> _artistFuture;
  bool _isFollowing = false;

  final List<Tab> _tabs = [
    Tab(text: 'Tiểu sử'),
    Tab(text: 'Bài hát'),
    Tab(text: 'Album'),
  ];

  @override
  void initState() {
    super.initState();
    _artistFuture = getIt<ApiKit>().getArtistInfo(widget.artistAlias);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Future<void> _loadArtist() async {
  //   _artist = await getIt<ApiKit>().getArtistInfo(widget.artistAlias) ?? null;
  //   _songs = await _loadArtistSongs();
  //   _albums = await _loadArtistAlbums();
  // }

  // Future<List<SongModel>> _loadArtistSongs() async {
  //   final artist = await _artistFuture;
  //   if (artist == null) return [];

  //   List<SongModel> songs = [];
  //   for (var song in artist.toJson()['artist']['sections'][0]['items']) {
  //     songs.add(await SongModel.fromJson<SupabaseApi>(song));
  //   }
  //   log('songs: ${songs.length}');
  //   return songs;
  // }

  // Future<List<PlaylistModel>> _loadArtistAlbums() async {
  //   final artist = await _artistFuture;
  //   if (artist == null) return [];
  //   final response = await getIt<ZingMp3Requester>().getListArtistAlbum(
  //     artistId: artist.id,
  //     page: 1,
  //     count: 20,
  //   );
  //   if (response['err'] != 0) return [];
  //   return PlaylistModel.fromListJson<ZingMp3Api>(response['data']['items']);
  // }

  // Future<void> _playAllSongs() async {
  //   final songs = await _songsFuture;
  //   if (songs.isNotEmpty) {
  //     await getIt<SongPlayerCubit>().loadAndPlay(
  //       context,
  //       songs.first,
  //       songList: songs,
  //     );
  //   }
  // }

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
                          MediaQuery.of(
                            context,
                          ).size.height, // or a fixed height if you prefer
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _ArtistInfo(artist: artist),
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
                ],
              ),

              Positioned(bottom: 5, left: 0, right: 0, child: getMiniPlayer()),
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
                      Theme.of(context).scaffoldBackgroundColor.withAlpha(220),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.5, 0.8, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
        ),

        // Artist name and buttons
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Play button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Phát nhạc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  // ToDO: follow API
                  OutlinedButton.icon(
                    icon: Icon(_isFollowing ? Icons.check : Icons.add),
                    label: Text(_isFollowing ? 'Đã theo dõi' : 'Theo dõi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isFollowing = !_isFollowing;
                        unawaited(
                          getIt<SupabaseArtistsApi>().toggleFollowArtist(
                            artist.id,
                          ),
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // Tab bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: TabBar(controller: _tabController, tabs: _tabs),
        ),
      ],
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
            'Tên thật:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('${artist.realname}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
        ],
        if (artist.biography != null) ...[
          const Text(
            'Tiểu sử',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ExpandableHtml(htmlText: artist.biography ?? ''),
          const SizedBox(height: 24),
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
    return Container(
      height: MediaQuery.of(context).size.height,

      child: ListView.builder(
        itemBuilder: (context, index) {
          final song = songs[index];
          return _SongListTile(song: song);
        },
        itemCount: songs.length,
      ),
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

        return Card(
          elevation: isPlaying ? 4 : 1,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                isPlaying
                    ? BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    )
                    : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await playerCubit.loadAndPlay(
                context,
                song,
                songList: List<SongModel>.from([song]),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Thumbnail with animation
                  Stack(
                    children: [
                      Hero(
                        tag: 'song_${song.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
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
                  // Song info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isPlaying ? FontWeight.bold : FontWeight.normal,
                            color:
                                isPlaying
                                    ? Theme.of(context).primaryColor
                                    : null,
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
                  // Play/Pause button
                  PlayOrPauseButton(
                    song: song,
                    color:
                        isPlaying
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600] ?? Colors.grey,
                  ),
                ],
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
    return Padding(
      padding: const EdgeInsets.all(16),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album cover with gradient overlay
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
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Album info
            Padding(
              padding: const EdgeInsets.all(12),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (album.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      album.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
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
