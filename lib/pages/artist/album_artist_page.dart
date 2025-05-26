import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:memecloud/components/artist/album_list_tile.dart';
import 'package:memecloud/components/miscs/search_bar.dart';
import 'package:memecloud/models/playlist_model.dart';

class AlbumArtistPage extends StatefulWidget {
  final List<PlaylistModel> albums;

  const AlbumArtistPage({super.key, required this.albums});

  @override
  State<AlbumArtistPage> createState() => _AlbumArtistPageState();
}

class _AlbumArtistPageState extends State<AlbumArtistPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final TextEditingController _searchController = TextEditingController();
  List<PlaylistModel> _filteredAlbums = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listenToScroll);
    _filteredAlbums = widget.albums;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listenToScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterAlbums(String query) {
    setState(() {
      _filteredAlbums =
          widget.albums
              .where(
                (album) =>
                    album.title.toLowerCase().contains(query.toLowerCase()),
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
                child: Icon(Icons.arrow_upward),
              )
              : null,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const SliverAppBar(title: Text("Các album")),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MySearchBar(
                variant: 2,
                searchQueryController: _searchController,
                onChanged: _filterAlbums,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final album = _filteredAlbums[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AlbumListTile(album: album),
                );
              }, childCount: _filteredAlbums.length),
            ),
          ),
        ],
      ),
    );
  }
}
