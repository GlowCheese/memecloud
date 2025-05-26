import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:memecloud/components/artist/followed_artist_tile.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/miscs/search_bar.dart';
import 'package:memecloud/models/artist_model.dart';

class FollowedArtistPage extends StatefulWidget {
  final List<ArtistModel> artists;

  const FollowedArtistPage({super.key, required this.artists});

  @override
  State<FollowedArtistPage> createState() => _FollowedArtistPageState();
}

class _FollowedArtistPageState extends State<FollowedArtistPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final TextEditingController _searchController = TextEditingController();
  List<ArtistModel> _filteredArtists = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listenToScroll);
    _filteredArtists = widget.artists;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listenToScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterArtists(String query) {
    setState(() {
      _filteredArtists =
          widget.artists
              .where(
                (artist) =>
                    artist.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
    log('Filtered artists: $_filteredArtists');
    log('Query for artists: $query');
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
        if (_showBackToTopButton) {
          return;
        }
        setState(() {
          _showBackToTopButton = true;
        });
      } else {
        if (!_showBackToTopButton) {
          return;
        }
        setState(() {
          _showBackToTopButton = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artists.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.no_accounts, size: 80),
            Text("Bạn chưa theo dõi nghệ sĩ nào."),
          ],
        ),
      );
    }
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
      appBar: AppBar(title: const Text("Nghệ sĩ đã theo dõi")),

      body: CustomScrollView(
        controller: _scrollController,

        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const SliverAppBar(title: Text("Các nghệ sĩ")),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MySearchBar(
                variant: 2,
                searchQueryController: _searchController,
                onChanged: _filterArtists,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final artist = _filteredArtists[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FollowedArtistTile(artist: artist),
                );
              }, childCount: _filteredArtists.length),
            ),
          ),
        ],
      ),
    );
  }
}
