import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/mini_player.dart';
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
  bool _isFollowing = false;

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

  Future<void> _playAllSongs() async {
    final songs = await _songsFuture;
    if (songs.isNotEmpty) {
      await getIt<SongPlayerCubit>().loadAndPlay(
        context,
        songs.first,
        songList: songs,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: getMiniPlayer(),
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
              SliverToBoxAdapter(child: _artistHeader(artist)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _artistInfo(artist),
                ),
              ),
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

        // Back button
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
          bottom: 16,
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
                    onPressed: _playAllSongs,
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
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _artistInfo(ArtistModel artist) {
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
          Html(data: artist.biography),
          const SizedBox(height: 24),
        ],
        const Text(
          'Bài hát',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<SongModel>>(
          future: _songsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final songs = snapshot.data ?? [];
            if (songs.isEmpty) {
              return const Center(child: Text('Chưa có bài hát nào'));
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
        await getIt<SongPlayerCubit>().loadAndPlay(
          context,
          song,
          songList: List<SongModel>.from([song]),
        );
      },
    );
  }
}

Widget _loadingArtist() {
  return const Center(child: CircularProgressIndicator());
}
