import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:memecloud/models/song_model.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

Padding _header(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
      ],
    ),
  );
}

class NewReleasesSection extends StatelessWidget {
  const NewReleasesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dartz.Either>(
      future: getIt<ApiKit>().getSongsForHome(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error loading songs ${snapshot.error}'));
        }

        final songsEither = snapshot.data!;
        return songsEither.fold(
          (error) => Center(child: Text('Error: $error')),
          (songLists) => _SongListDisplay(songLists),
        );
      },
    );
  }
}

class _SongListDisplay extends StatefulWidget {
  final List songLists;

  const _SongListDisplay(this.songLists);

  @override
  State<_SongListDisplay> createState() => _SongListDisplayState();
}

class _SongListDisplayState extends State<_SongListDisplay> {
  late String title;
  late List<SongModel> songList;

  @override
  void initState() {
    super.initState();
    title = widget.songLists[0]['title'];
    songList = List<SongModel>.from(widget.songLists[0]['items']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(title),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 220),
          child: ScrollSnapList(
            initialIndex: 1,
            scrollDirection: Axis.horizontal,
            itemSize: 150,
            itemCount: songList.length,
            dynamicItemSize: true,
            onItemFocus: (index) {},
            itemBuilder: (context, index) {
              final song = songList[index];
              return _songCardDisplay(context, song);
            },
          ),
        ),
      ],
    );
  }

  GestureDetector _songCardDisplay(BuildContext context, SongModel song) {
    final colorScheme = AdaptiveTheme.of(context).theme.colorScheme;

    return GestureDetector(
        onTap: () async {
          if (!(await getIt<SongPlayerCubit>().loadAndPlay(context, song, songList: songList))) {
            setState(() {
              songList.remove(song);
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: song.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, err) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 150,
              child: Text(
                song.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 130,
              child: Text(
                song.artistsNames,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withAlpha(156),
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
  }
}
