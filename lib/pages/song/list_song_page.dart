import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:memecloud/components/artist/song_list_tile.dart';
import 'package:memecloud/components/miscs/search_bar.dart';

import 'package:memecloud/models/song_model.dart';

class ListSongPage extends StatefulWidget {
  final List<SongModel> songs;
  final String? playlistId;

  const ListSongPage({super.key, required this.songs, this.playlistId});

  @override
  State<ListSongPage> createState() => _ListSongPageState();
}

class _ListSongPageState extends State<ListSongPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final TextEditingController _searchController = TextEditingController();
  List<SongModel> _filteredSongs = [];
  bool anySongAdded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listenToScroll);
    _filteredSongs = widget.songs;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listenToScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterSongs(String query) {
    setState(() {
      _filteredSongs =
          widget.songs
              .where(
                (song) =>
                    song.title.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
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
                child: const Icon(Icons.arrow_upward),
              )
              : null,
      body: CustomScrollView(
        controller: _scrollController,

        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            title: const Text("Các bài hát"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, anySongAdded);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MySearchBar(
                variant: 2,
                searchQueryController: _searchController,
                onChanged: _filterSongs,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = _filteredSongs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SongListTile(
                    song: song,
                    variant: 2,
                    playlistId: widget.playlistId,
                    onSongAdded: (added) {
                      if (added) {
                        anySongAdded = true;
                      }
                    },
                  ),
                );
              }, childCount: _filteredSongs.length),
            ),
          ),
        ],
      ),
    );
  }
}
