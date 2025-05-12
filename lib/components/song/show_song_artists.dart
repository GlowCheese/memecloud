import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/components/miscs/bottom_sheet_dragger.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/components/musics/artist_card.dart';

void showSongArtists(BuildContext context, List<ArtistModel> artists) {
  if (artists.isEmpty) return;

  if (artists.length == 1) {
    context.pushReplacement('/artist_page', extra: artists[0].alias);
    return;
  }

  final artistCards =
      artists
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: ArtistCard(variation: 2, artist: e, pushReplacement: true),
            ),
          )
          .toList();

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const BottomSheetDragger(),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Nghệ sĩ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            ...artistCards,
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
