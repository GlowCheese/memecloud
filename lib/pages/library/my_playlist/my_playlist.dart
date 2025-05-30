import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/pages/library/my_playlist/create_new_playlist.dart';

class MyPlaylistPage extends StatefulWidget {
  const MyPlaylistPage({super.key});

  @override
  State<MyPlaylistPage> createState() => _MyPlaylistPageState();
}

class _MyPlaylistPageState extends State<MyPlaylistPage> {
  late Future<List<PlaylistModel>> Function() _myPlaylistFuture;

  @override
  void initState() {
    _myPlaylistFuture = getIt<ApiKit>().supabase.userPlaylist.getUserPlaylists;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            title: Text(
              'Your Playlists',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // Your Playlists Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Của bạn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Your Playlists Grid
          FutureBuilder<List<PlaylistModel>>(
            future: _myPlaylistFuture(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Text('Lỗi: ${snapshot.error}'),
                );
              }

              final playlists = snapshot.data ?? [];

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index > 0) {
                      return _buildPlaylistCard(
                        playlist: playlists[index - 1],

                        color:
                            Colors.primaries[index % Colors.primaries.length],
                      );
                    } else {
                      return _addPlaylistCard();
                    }
                  }, childCount: playlists.length + 1),
                ),
              );
            },
          ),

          // Suggested Playlists Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Có thể bạn thích?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Suggested Playlists List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSuggestedPlaylistItem(
                  'Suggested Playlist ${index + 1}',
                  '${(index + 1) * 10} songs',
                  Colors.primaries[(index + 6) % Colors.primaries.length],
                ),
                childCount: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard({
    required PlaylistModel playlist,
    required Color color,
  }) {
    final thumbnailUrl = playlist.thumbnailUrl;
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: () => context.push('/playlist_page', extra: playlist),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              playlist.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(playlist.description ?? '', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedPlaylistItem(
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.playlist_play, color: color),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _addPlaylistCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateNewPlaylist()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add, color: Colors.white, size: 40),
              SizedBox(height: 8),
              Text('Tạo playlist', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
