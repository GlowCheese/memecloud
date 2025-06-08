import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/success.dialog.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/common/confirmation_dialog.dart';
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
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

          FutureBuilder<List<PlaylistModel>>(
            future: _myPlaylistFuture(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
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
                sliver: SliverList(
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Chỉnh sửa'),
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
                        leading: const Icon(Icons.delete),
                        title: const Text('Xóa'),
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

        child: PlaylistCard(
          fetchNew: false,
          playlist: playlist,
        ).variant2(size: 40),
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
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.add, color: Colors.white, size: 40),
              SizedBox(width: 80),
              Text('Tạo playlist mới', style: TextStyle(color: Colors.white)),
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
