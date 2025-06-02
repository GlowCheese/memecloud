import 'package:flutter/material.dart';
import 'dart:math';

class AlbumCard {
  String name;
  Color boxColor;
  String coverPath;

  AlbumCard({
    required this.name,
    required this.boxColor,
    required this.coverPath,
  });

  static List<AlbumCard> getTopAlbums() {
    List<AlbumCard> albumCards = [];

    albumCards.add(
      AlbumCard(
        name: 'KPop',
        boxColor: const Color(0xFF75C922),
        coverPath: 'assets/album_covers/kpop.png',
      ),
    );

    albumCards.add(
      AlbumCard(
        name: 'Indie',
        boxColor: const Color(0xFFCF25A0),
        coverPath: 'assets/album_covers/indie.jpeg',
      ),
    );

    albumCards.add(
      AlbumCard(
        name: 'R&B',
        boxColor: const Color(0xFF4A558F),
        coverPath: 'assets/album_covers/rnb.png',
      ),
    );

    albumCards.add(
      AlbumCard(
        name: 'Pop',
        boxColor: const Color(0xFFBD6220),
        coverPath: 'assets/album_covers/pop.png',
      ),
    );

    return albumCards;
  }

  static List<AlbumCard> getAllAlbums() {
    List<AlbumCard> albumCards = [];

    albumCards.add(
      AlbumCard(
        name: 'Made\nfor You',
        boxColor: const Color(0xFF1E82AC),
        coverPath: 'assets/album_covers/4you.png',
      ),
    );

    albumCards.add(
      AlbumCard(
        name: 'RELEASED',
        boxColor: const Color(0xFF76259C),
        coverPath: 'assets/album_covers/released.png',
      ),
    );

    albumCards.add(
      AlbumCard(
        name: 'Music\nCharts',
        boxColor: const Color(0xFF25319C),
        coverPath: 'assets/album_covers/music-chart.png',
      ),
    );

    albumCards.add(
      AlbumCard(
        name: 'Podcasts',
        boxColor: const Color(0xFF92233E),
        coverPath: 'assets/album_covers/podcasts.png',
      ),
    );

    albumCards.add(
      AlbumCard(
        name: 'Bollywood',
        boxColor: const Color(0xFFC48E1C),
        coverPath: 'assets/album_covers/bollywood.png',
      ),
    );

    albumCards.add(
      AlbumCard(
        name: 'Pop\nFusion',
        boxColor: const Color(0xFF318C65),
        coverPath: 'assets/album_covers/pop-fusion.jpeg',
      ),
    );

    return albumCards;
  }
}

class AlbumCardWidget extends StatelessWidget {
  final AlbumCard album;

  const AlbumCardWidget({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110,
        color: album.boxColor,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15, top: 10
                ),
                child: Text(
                  album.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Positioned(
              right: -20,
              bottom: -40,
              child: Transform.rotate(
                angle: pi / 15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    album.coverPath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover
                  ),
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}
