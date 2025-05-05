import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/pages/artist/artist_page.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class TopArtistsSection extends StatelessWidget {
  const TopArtistsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getTopArtists(5),
      onData: (context, artists) {
        return _artistView(artists);
      },
    );
  }
}

Widget _artistView(List<ArtistModel> artists) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nghệ sĩ nổi bật',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
          ],
        ),
      ),
      SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return _artistTile(context, artist);
          },
        ),
      ),
    ],
  );
}

Widget _artistTile(BuildContext context, ArtistModel artist) {
  return GestureDetector(
    onTap:
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArtistPage(artistAlias: artist.alias),
          ),
        ),
    child: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2196F3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withAlpha(20),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: artist.thumbnailUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}
