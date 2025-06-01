import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/common/confirmation_dialog.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/success.dialog.dart';
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
  late Future<List<PlaylistModel>> Function() _suggestedPlaylistFuture;

  @override
  void initState() {
    _myPlaylistFuture = getIt<ApiKit>().supabase.userPlaylist.getUserPlaylists;
    _suggestedPlaylistFuture =
        getIt<ApiKit>().supabase.playlists.getSuggestedPlaylists;
    super.initState();
  }

  void refreshMyPlaylist() {
    setState(() {
      _myPlaylistFuture =
          getIt<ApiKit>().supabase.userPlaylist.getUserPlaylists;
    });
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
          FutureBuilder<List<PlaylistModel>>(
            future: _suggestedPlaylistFuture(),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSuggestedPlaylistItem(
                      playlist: playlists[index],
                      color:
                          Colors.primaries[(index + 6) %
                              Colors.primaries.length],
                    ),
                    childCount: playlists.length,
                  ),
                ),
              );
            },
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
        onLongPress: () {
          // chỉnh sửa/ xóa
          showModalBottomSheet(
            context: context,
            builder:
                (context) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        playlist.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Chỉnh sửa'),
                        onTap: () async {
                          Navigator.pop(context);
                          final hasBeenEdited = await Navigator.of(
                            context,
                          ).push(
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      CreateNewPlaylist(playlist: playlist),
                            ),
                          );
                          if (hasBeenEdited) {
                            refreshMyPlaylist();
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Xóa'),
                        onTap: () async {
                          Navigator.pop(context);
                          _showDeletePlaylistDialog(context, playlist);
                        },
                      ),
                    ],
                  ),
                ),
          );
        },

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

  Widget _buildSuggestedPlaylistItem({
    required PlaylistModel playlist,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: GestureDetector(
          onTap: () => context.push('/playlist_page', extra: playlist),
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
              child: CachedNetworkImage(imageUrl: playlist.thumbnailUrl),
            ),
            title: Text(
              playlist.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              playlist.description ?? '',
              style: TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _addPlaylistCard() {
    return GestureDetector(
      onTap: () async {
        final hasBeenAdded = await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreateNewPlaylist()));
        if (hasBeenAdded == true) {
          refreshMyPlaylist();
        }
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

  void _showDeletePlaylistDialog(
    BuildContext context,
    PlaylistModel playlist,
  ) async {
    final submitUnfollow = await ConfirmationDialog.show(
      context: context,
      title: 'Xóa playlist',
      message: 'Bạn có chắc chắn muốn xóa playlist ${playlist.title} không?',
      confirmText: 'Xóa',
      cancelText: 'Không',
    );

    if (submitUnfollow == true) {
      try {
        await getIt<ApiKit>().supabase.userPlaylist.deletePlaylist(
          playlistId: playlist.id,
        );
        refreshMyPlaylist();
        if (context.mounted) {
          showSuccessDialog(
            context,
            text: 'Xóa playlist thành công',
            numOfPopContext: 1,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xóa playlist thất bại. Lỗi: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }
}
