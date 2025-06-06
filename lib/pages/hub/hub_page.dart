import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/components/miscs/data_inspector.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/sections/section_card.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/pages/ssp/simple_scrollable_page.dart';

class HubPage extends StatelessWidget {
  final String hubId;

  const HubPage({super.key, required this.hubId});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getHubDetail(hubId: hubId),
      onData: (context, data) => _HubPageInner(data),
    );
  }
}

class _HubPageInner extends StatelessWidget {
  final Map<String, dynamic> json;

  const _HubPageInner(this.json);

  @override
  Widget build(BuildContext context) {
    return SimpleScrollablePage(spacing: 24, title: json['title']).variant1(
      children: [
        const SizedBox(),
        if (json.containsKey('cover')) _cover(json['cover']),
        for (Map<String, dynamic> section in json['sections'])
          if (section['sectionType'] == 'playlist' &&
              section['viewType'] == 'slider' &&
              // I don't know why this is necessary, but it does
              section.containsKey('items'))
            SectionCard(title: section['title']).variant3_1(
              playlists: PlaylistModel.fromListJson<ZingMp3Api>(
                section['items'],
              ),
            )
          else if (section['sectionType'] == 'song' &&
              section['viewType'] == 'slider')
            SectionCard(title: section['title']).variant3_3(
              songs: SongModel.fromListJson<ZingMp3Api>(section['items']),
              songsPerCol: 4,
              titlePadding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 8,
              ),
            )
          else if (section['sectionType'] == 'artist' &&
              section['viewType'] == 'slider')
            SectionCard(title: section['title']).variant3_4(
              artists: ArtistModel.fromListJson<ZingMp3Api>(section['items']),
            ),
        const SizedBox(),
      ],
    );
  }

  Widget _cover(String coverUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: CachedNetworkImage(
          imageUrl: coverUrl,
          fit: BoxFit.cover,
          height: 110,
          width: double.infinity,
        ),
      ),
    );
  }
}
