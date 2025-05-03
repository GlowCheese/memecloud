import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/search_result_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/default_future_builder.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';

class SearchResult extends StatefulWidget {
  final String queryString;

  const SearchResult(this.queryString, {super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().searchMulti(widget.queryString),
      onData: (context, searchResult) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bestMatchWidget(searchResult),
            _SearchNavigation(searchResult),
          ],
        );
      },
    );
  }

  Widget bestMatchWidget(SearchResultModel searchResult) {
    if (searchResult.bestMatch == null) {
      return SizedBox();
    } else {
      final Widget item = simpleWingetDecode(context, searchResult.bestMatch!);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Best match:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 5),
            item,
          ],
        ),
      );
    }
  }
}

class _SearchNavigation extends StatefulWidget {
  final SearchResultModel searchResult;

  const _SearchNavigation(this.searchResult);

  @override
  State<_SearchNavigation> createState() => _SearchNavigationState();
}

class _SearchNavigationState extends State<_SearchNavigation> {
  int filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    late List<dynamic> filterData;

    final Map<String, List> filterMap = {
      'Songs': widget.searchResult.songs,
      'Artists': widget.searchResult.artists,
      'Playlists': widget.searchResult.playlists,
    };

    filterMap.forEach((label, searchFilter) {
      if (searchFilter.isNotEmpty) {
        final buttonsLength = buttons.length;
        if (filterIndex == buttonsLength) {
          filterData = searchFilter;
        }
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child:
                (filterIndex == buttonsLength)
                    ? (FilledButton(
                      onPressed: () {
                        setState(() => filterIndex = buttonsLength);
                      },
                      child: Text(label),
                    ))
                    : (ElevatedButton(
                      onPressed: () {
                        setState(() => filterIndex = buttonsLength);
                      },
                      child: Text(label),
                    )),
          ),
        );
      }
    });

    List<SongModel>? songList;
    if (filterData.isNotEmpty && filterData[0] is SongModel) {
      songList = List<SongModel>.from(filterData);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5, top: 10),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              children: buttons,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          child: Column(
            spacing: 14,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                filterData
                    .map(
                      (e) => simpleWingetDecode(context, e, songList: songList),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}

Padding pageDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Divider(
      color: Colors.white,
      thickness: 1,
      indent: 30,
      endIndent: 30,
    ),
  );
}

Widget simpleWingetDecode(
  BuildContext context,
  Object item, {
  List<SongModel>? songList,
}) {
  late String text;
  String? subText;
  late String thumbnailUrl;

  if (item is SongModel) {
    text = item.title;
    subText = item.artistsNames;
    thumbnailUrl = item.thumbnailUrl;
  } else if (item is ArtistModel) {
    text = item.name;
    thumbnailUrl = item.thumbnailUrl;
  } else if (item is PlaylistModel) {
    text = item.title;
    subText = item.artistsNames!;
    thumbnailUrl = item.thumbnailUrl;
  } else {
    throw 'Invalid type of item: ${item.runtimeType}';
  }

  Widget widget = Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: CachedNetworkImage(
          imageUrl: thumbnailUrl,
          width: 40,
          height: 40,
        ),
      ),
      SizedBox(width: 14),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subText == null
                ? SizedBox()
                : (Text(
                  subText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
      ),
    ],
  );

  if (item is! SongModel) {
    return widget;
  }

  return GestureDetector(
    onTap: () async {
      await getIt<SongPlayerCubit>().loadAndPlay(
        context,
        item,
        songList: songList,
      );
    },
    child: widget,
  );
}
