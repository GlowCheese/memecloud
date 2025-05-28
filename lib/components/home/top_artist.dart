import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/pages/artist/all_artist_page.dart';

class TopArtistsSection extends StatelessWidget {
  const TopArtistsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getTopArtists(count: 5),
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
          ],
        ),
      ),
      SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const RangeMaintainingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: artists.length + 1,
          itemBuilder: (context, index) {
            if (index < artists.length) {
              final artist = artists[index];
              return _artistTile(context, artist);
            }
            return _showAllArtistsButton(context);
          },
        ),
      ),
    ],
  );
}

Widget _showAllArtistsButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllArtistPage()));
    },
    child: Container(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_circle_right,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Xem tất cả',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _artistTile(BuildContext context, ArtistModel artist) {
  return GestureDetector(
    onTap: () {
      context.push('/artist_page', extra: artist.alias);
    },
    child: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2),
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
