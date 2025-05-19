import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/components/artist/song_list_tile.dart';
import 'package:memecloud/components/song/play_or_pause_button.dart';
import 'package:memecloud/core/getit.dart';

import 'package:memecloud/models/song_model.dart';

class SongArtistPage extends StatelessWidget {
  final List<SongModel> songs;

  const SongArtistPage({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(title: Text("Các bài hát")),
          // Songs list
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = songs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SongListTile(song: song),
                );
              }, childCount: songs.length),
            ),
          ),
        ],
      ),
    );
  }
}