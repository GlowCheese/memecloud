import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/search_result_model.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/musics/artist_card.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class SearchResultView extends StatefulWidget {
  final String keyword;

  const SearchResultView(this.keyword, {super.key});

  @override
  State<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> {
  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().searchMulti(widget.keyword),
      onData: (context, searchResult) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bestMatchWidget(searchResult),
            SizedBox(height: 14),
            _SearchNavigation(widget.keyword, searchResult),
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
        padding: const EdgeInsets.only(left: 30, right: 30, top: 14),
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
  final String keyword;
  final SearchResultModel searchResult;

  const _SearchNavigation(this.keyword, this.searchResult);

  @override
  State<_SearchNavigation> createState() => _SearchNavigationState();
}

class _SearchNavigationState extends State<_SearchNavigation> {
  int filterIndex = -1;

  late final filterMap = {
    'Bài hát': (int page) {
      return getIt<ApiKit>().searchSongs(widget.keyword, page: page);
    },
    'Nghệ sĩ': (int page) {
      return getIt<ApiKit>().searchArtists(widget.keyword, page: page);
    },
    'Danh sách phát': (int page) {
      return getIt<ApiKit>().searchPlaylists(widget.keyword, page: page);
    },
  };
  List<bool> hasMore = [true, true, true];
  List<List<Object>> cachedFilterData = [[], [], []];

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];

    dynamic filterData;
    filterMap.forEach((label, filterFunc) {
      final buttonsLength = buttons.length;
      if (filterIndex == buttonsLength) {
        filterData = filterFunc;
      }
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child:
              (filterIndex == buttonsLength)
                  ? (FilledButton(
                    onPressed: () {
                      setState(() => filterIndex = -1);
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
    });

    late Widget content;

    if (filterIndex == -1) {
      filterData = mixLists([
        widget.searchResult.songs,
        widget.searchResult.artists,
        widget.searchResult.playlists,
      ]);
      content = _searchTop(List<Object>.from(filterData), context);
    } else {
      content = _filteredSearch(filterData);
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
          child: content,
        ),
      ],
    );
  }

  Widget _searchTop(List<Object> filterData, BuildContext context) {
    List<SongModel> songList = [];
    for (Object item in filterData) {
      if (item is SongModel) {
        songList.add(item);
      }
    }

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          filterData
              .map((e) => simpleWingetDecode(context, e, songList: songList))
              .toList(),
    );
  }

  Widget _filteredSearch(Future<List<Object>?> Function(int page) searchGen) {
    final dataList = cachedFilterData[filterIndex];
    List<SongModel>? songList;
    if (filterIndex == 0) {
      songList = List.castFrom<dynamic, SongModel>(dataList);
    }

    return SizedBox(
      height: 420,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: dataList.length + (hasMore[filterIndex] ? 1 : 0),
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index < dataList.length) {
            return simpleWingetDecode(
              context,
              dataList[index],
              songList: songList,
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () async {
                final data = await searchGen(
                  (dataList.length / 16).round() + 1,
                );
                if (data == null) {
                  setState(() {
                    hasMore[filterIndex] = false;
                    dataList.add(Center(child: Text('No more result')));
                  });
                } else {
                  setState(() {
                    dataList.addAll(data);
                  });
                }
              },
              child: Text('Load more...'),
            ),
          );
        },
      ),
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
  if (item is SongModel) {
    return SongCard(variation: 1, song: item, songList: songList);
  }
  if (item is PlaylistModel) {
    return PlaylistCard(variation: 1, playlist: item);
  }
  if (item is ArtistModel) {
    return ArtistCard(variation: 1, artist: item);
  }
  throw UnsupportedError("Invalid item type: ${item.runtimeType}");
}
