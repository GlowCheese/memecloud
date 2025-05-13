import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/week_chart_model.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/song/like_button.dart';
import 'package:memecloud/components/song/play_or_pause_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_stream.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/song/like_button.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

Map getTopChartPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Top Charts'),
    'bgColor': MyColorSet.grey,
    'floatingActionButton': null,
    'body': TopChartPage(),
  };
}

class TopChartPage extends StatefulWidget {
  const TopChartPage({super.key});

  @override
  State<TopChartPage> createState() => _TopChartPageState();
}

class _TopChartPageState extends State<TopChartPage>
    with SingleTickerProviderStateMixin {
  // TabController to control the tabs
  late TabController _tabController;
  final ApiKit _apiKit = getIt<ApiKit>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSongItem(ChartSong chartSong, int index) {
    final song = chartSong.song;
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              // Display the rank number
              '${index + 1}',
              style: TextStyle(
                color:
                    index == 0
                        ? Colors.yellow
                        : index == 1
                        ? Colors.grey
                        : index == 2
                        ? Colors.brown
                        : Colors.white,
                fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                fontSize: index < 3 ? 24 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: song.thumbnailUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        song.artistsNames,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayOrPauseButton(song: song),
          const SizedBox(width: 8),
          SongLikeButton(song: song),
        ],
      ),
    );
  }

  Widget _buildChartTab(Future<WeekChartModel> Function() chartFetcher) {
    return defaultFutureBuilder<WeekChartModel>(
      future: chartFetcher(),
      onData: (context, chart) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16),
          itemCount: chart.songs.length,
          itemBuilder: (context, index) {
            final chartSong = chart.songs[index];
            return _buildSongItem(chartSong, index);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'V-Pop'),
            Tab(text: 'US-UK'),
            Tab(text: 'K-Pop'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        TabBarView(
          controller: _tabController,
          children: [
            _buildChartTab(() => _apiKit.getVpopWeekChart()),
            _buildChartTab(() => _apiKit.getUsukWeekChart()),
            _buildChartTab(() => _apiKit.getKpopWeekChart()),
          ],
        ),
      ],
    );
  }
}
