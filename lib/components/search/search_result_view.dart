import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';
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
import 'package:memecloud/components/miscs/section_divider.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/miscs/generatable_list/list_view.dart';

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
            Expanded(child: SearchNavigation(widget.keyword, searchResult)),
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text('Best match:', style: TextStyle(fontSize: 20)),
          ),
          SizedBox(height: 5),
          item,
        ],
      );
    }
  }
}

class SearchNavigation extends StatefulWidget {
  final String keyword;
  final SearchResultModel searchResult;

  const SearchNavigation(this.keyword, this.searchResult, {super.key});

  @override
  State<SearchNavigation> createState() => _SearchNavigationState();
}

class _SearchNavigationState extends State<SearchNavigation> {
  late final filterMap = {
    'Bài hát': getIt<ApiKit>().searchSongs,
    'Nghệ sĩ': getIt<ApiKit>().searchArtists,
    'Danh sách phát': getIt<ApiKit>().searchPlaylists,
  };

  @override
  Widget build(BuildContext context) {
    final tabBodies =
        filterMap.values.map((fetchF) {
          return GeneratableListView(
            key: ValueKey(fetchF),
            initialPageIdx: 1,
            asyncGenFunction: (page) async {
              final data = await fetchF(widget.keyword, page: page);
              if (data == null) return null;

              List<SongModel>? songList;
              if (data.firstOrNull is SongModel) {
                songList = List.castFrom(data);
              }
              return data
                  .map(
                    (e) => simpleWingetDecode(context, e, songList: songList),
                  )
                  .toList();
            },
            separatorBuilder: (context, index) => SizedBox(height: 16),
          );
        }).toList();

    return PageWithSingleTab(
      variant: 1,
      tabNames: filterMap.keys.toList(),
      tabBodies: tabBodies,
      nullTab: _searchTop(
        List.castFrom<dynamic, Object>(
          mixLists([
            widget.searchResult.songs,
            widget.searchResult.artists,
            widget.searchResult.playlists,
          ]),
        ),
        context,
      ),
      widgetBuilder: (tabsNavigator, tabContent) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: tabsNavigator),
            const SectionDivider(),
            Expanded(child: tabContent),
          ],
        );
      },
    );
  }

  Widget _searchTop(List<Object> filterData, BuildContext context) {
    List<SongModel> songList = [];
    for (Object item in filterData) {
      if (item is SongModel) {
        songList.add(item);
      }
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        return simpleWingetDecode(
          context,
          filterData[index],
          songList: songList,
        );
      },
      itemCount: filterData.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
    );
  }
}

Widget simpleWingetDecode(
  BuildContext context,
  Object item, {
  List<SongModel>? songList,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: () {
      if (item is SongModel) {
        return SongCard(variant: 1, song: item, songList: songList);
      }
      if (item is PlaylistModel) {
        return PlaylistCard(variant: 1, playlist: item);
      }
      if (item is ArtistModel) {
        return ArtistCard(variant: 1, artist: item);
      }
      throw UnsupportedError("Invalid item type: ${item.runtimeType}");
    }(),
  );
}
