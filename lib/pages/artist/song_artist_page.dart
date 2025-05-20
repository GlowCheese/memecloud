import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:memecloud/components/artist/song_list_tile.dart';

import 'package:memecloud/models/song_model.dart';

class SongArtistPage extends StatefulWidget {
  final List<SongModel> songs;

  const SongArtistPage({super.key, required this.songs});

  @override
  State<SongArtistPage> createState() => _SongArtistPageState();
}

class _SongArtistPageState extends State<SongArtistPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listenToScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listenToScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _listenToScroll() {
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        if (!_showBackToTopButton) {
          setState(() {
            log("show back to top button");
            _showBackToTopButton = true;
          });
        }
      } else {
        if (_showBackToTopButton) {
          setState(() {
            _showBackToTopButton = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          _showBackToTopButton
              ? FloatingActionButton(
                onPressed: () {
                  _scrollToTop();
                },
                tooltip: "Về đầu trang",
                child: Icon(Icons.arrow_upward),
              )
              : null,
      body: CustomScrollView(
        controller: _scrollController,

        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const SliverAppBar(title: Text("Các bài hát")),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = widget.songs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SongListTile(song: song),
                );
              }, childCount: widget.songs.length),
            ),
          ),
        ],
      ),
    );
  }
}
