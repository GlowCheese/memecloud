import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:memecloud/apis/supabase/main.dart';

import 'package:memecloud/components/artist/song_list_tile.dart';
import 'package:memecloud/components/miscs/search_bar.dart';
import 'package:memecloud/core/getit.dart';

import 'package:memecloud/models/song_model.dart';

class ListSongPaginatePage extends StatefulWidget {
  final String? playlistId;

  const ListSongPaginatePage({super.key, this.playlistId});

  @override
  State<ListSongPaginatePage> createState() => _ListSongPaginatePageState();
}

class _ListSongPaginatePageState extends State<ListSongPaginatePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final TextEditingController _searchController = TextEditingController();
  
  List<SongModel> _allSongs = [];
  List<SongModel> _filteredSongs = [];
  bool anySongAdded = false;
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listenToScroll);
    _loadInitialSongs();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listenToScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSongs() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMoreData = true;
    });

    try {
      final songs = await getIt<SupabaseApi>().songs.getSongsPage(page: 0,limit:  _pageSize);
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _hasMoreData = songs.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error loading initial songs: $e');
    }
  }

  Future<void> _loadMoreSongs() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newSongs = await getIt<SupabaseApi>().songs.getSongsPage(page:  _currentPage + 1, limit:  _pageSize);
      
      setState(() {
        _currentPage++;
        _allSongs.addAll(newSongs);
        
        if (_currentSearchQuery.isEmpty) {
          _filteredSongs = _allSongs;
        } else {
          _filterSongs(_currentSearchQuery);
        }
        
        _hasMoreData = newSongs.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error loading more songs: $e');
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _currentSearchQuery = query;
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        _filteredSongs = _allSongs
            .where((song) =>
                song.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
    if (_scrollController.offset >= 300) {
      if (!_showBackToTopButton) {
        setState(() {
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

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_currentSearchQuery.isEmpty) { 
        _loadMoreSongs();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
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
          // Hiển thị loading indicator ở đầu khi load initial
          if (_isLoading && _filteredSongs.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          // Danh sách bài hát
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                },
                childCount: _filteredSongs.length,
              ),
            ),
          ),
          if (_isLoading && _filteredSongs.isNotEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          if (!_hasMoreData && _filteredSongs.isNotEmpty && _currentSearchQuery.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Đã hiển thị tất cả bài hát",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}