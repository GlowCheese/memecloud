import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/apis/zingmp3/requester.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';

class ArtistPage extends StatefulWidget {
  final String artistAlias;

  const ArtistPage({super.key, required this.artistAlias});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late Future<ArtistModel?> _artistFuture;
  late Future<List<SongModel>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _artistFuture = getIt<ApiKit>().getArtistInfo(widget.artistAlias);
    _songsFuture = _loadArtistSongs();
  }

  Future<List<SongModel>> _loadArtistSongs() async {
    final artist = await _artistFuture;
    if (artist == null) return [];
    final response = await getIt<ZingMp3Requester>().getListArtistSong(
      artistId: artist.id,
      page: 1,
      count: 20,
    );
    if (response['err'] != 0) return [];
    return SongModel.fromListJson<ZingMp3Api>(response['data']['items']);
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final artist = snapshot.data;
          if (artist == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin nghệ sĩ'),
            );
          }
          return CustomScrollView(
            slivers: [
              _ArtistAppBar(artist: artist),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (artist.realname != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tên thật: ${artist.realname}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (artist.biography != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Tiểu sử',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          artist.biography!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Bài hát',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<SongModel>>(
                        future: _songsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          final songs = snapshot.data ?? [];
                          if (songs.isEmpty) {
                            return const Center(
                              child: Text('Chưa có bài hát nào'),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              return _SongListTile(song: song);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArtistAppBar extends StatelessWidget {
  final ArtistModel artist;
  const _ArtistAppBar({required this.artist});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
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
                  colors: [Colors.transparent, Colors.black.withAlpha(70)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongListTile extends StatelessWidget {
  final SongModel song;
  const _SongListTile({required this.song});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: song.thumbnailUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artistsNames),
      onTap: () async {
        // TODO: play song
      },
    );
  }
}

Widget _loadingArtist() {
  return const Center(child: CircularProgressIndicator());
}
