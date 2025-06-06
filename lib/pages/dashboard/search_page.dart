import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/components/miscs/search_bar.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/sections/section_card.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/search/search_result_view.dart';
import 'package:memecloud/components/search/search_suggestions.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

Map getSearchPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Search'),
    'bgColor': MyColorSet.cyan,
    'body': const SearchPage(),
  };
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Timer? changeSearchQueryTask;
  String currentSearchKeyword = "";

  String? finalSearchQuery;
  bool searchBarIsFocused = false;
  final TextEditingController searchQueryController = TextEditingController();

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 35),
      child: MySearchBar(
        variant: 1,
        searchQueryController: searchQueryController,
        onTap: () {
          if (searchBarIsFocused == false || finalSearchQuery != null) {
            setState(() {
              finalSearchQuery = null;
              searchBarIsFocused = true;
            });
          }
        },
        onSubmitted: setSearchQuery,
        onChanged: (p0) {
          changeSearchQueryTask?.cancel();
          changeSearchQueryTask = Timer(
            Duration(milliseconds: p0.isEmpty ? 0 : 500),
            () => setState(() => currentSearchKeyword = p0),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchQueryController.dispose();
    changeSearchQueryTask?.cancel();
    super.dispose();
  }

  void setSearchQuery(String value) {
    getIt<ApiKit>().saveRecentSearch(value);
    FocusScope.of(context).unfocus();
    setState(() => finalSearchQuery = value);
    searchQueryController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    late Widget body;
    if (searchBarIsFocused == false) {
      body = defaultFutureBuilder(
        future: getIt<ApiKit>().getHubHome(),
        onData: (context, data) {
          return ScrollableZingHub(data);
        },
      );
    } else if (finalSearchQuery == null) {
      body = SearchSuggestions(
        searchKeyword: currentSearchKeyword,
        onSelect: setSearchQuery,
      );
    } else {
      body = SearchResultView(finalSearchQuery!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [searchBar(), Expanded(child: body)],
    );
  }
}

class ScrollableZingHub extends StatelessWidget {
  final Map<String, dynamic> hub;

  const ScrollableZingHub(this.hub, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyChildren = [
      const SizedBox(),

      if (hub.containsKey('banners'))
        _banner(
          context,
          List.castFrom<dynamic, Map<String, dynamic>>(hub['banners']),
        ),

      if (hub.containsKey('featured'))
        SectionCard(title: hub['featured']['title']).variant3_2(
          hubs: List.castFrom<dynamic, Map<String, dynamic>>(
            hub['featured']['items'],
          ),
        ),

      if (hub.containsKey('nations'))
        SectionCard(title: "Quốc Gia").variant3_2(
          hubs: List.castFrom<dynamic, Map<String, dynamic>>(hub['nations']),
        ),

      if (hub.containsKey('genre'))
        for (var item in hub['genre'])
          SectionCard(title: item['title']).variant3_1(
            playlists: PlaylistModel.fromListJson<ZingMp3Api>(
              item['playlists'],
            ),
          ),
    ];

    return ListView.separated(
      itemBuilder: (context, index) => bodyChildren[index],
      itemCount: bodyChildren.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
    );
  }

  Widget _banner(BuildContext context, List<Map<String, dynamic>> banners) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: CarouselSlider(
          items:
              banners.map((banner) {
                String id = banner['link']!.split('/').last.split('.').first;
                String cover = banner['cover']!;

                return GestureDetector(
                  onTap: () => context.push('/hub_page', extra: id),
                  child: CachedNetworkImage(
                    imageUrl: cover,
                    fit: BoxFit.cover,
                    height: 110,
                    width: double.infinity,
                  ),
                );
              }).toList(),
          options: CarouselOptions(
            height: 110,
            autoPlay: true,
            viewportFraction: 1,
          ),
        ),
      ),
    );
  }
}
