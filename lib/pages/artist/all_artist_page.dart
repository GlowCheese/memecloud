import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/musics/artist_card.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/artist_model.dart';

class AllArtistPage extends StatefulWidget {
  const AllArtistPage({super.key});

  @override
  State<AllArtistPage> createState() => _AllArtistPageState();
}

class _AllArtistPageState extends State<AllArtistPage> {
  final Future<List<ArtistModel>> Function({
    required int offset,
    required int limit,
  })
  artistsFuture = getIt<ApiKit>().supabase.artists.getAllArtists;

  final Future<List<ArtistModel>> Function(String query) artistsSearchFuture =
      getIt<ApiKit>().supabase.artists.getAllArtistsWithQuery;

  final List<ArtistModel> _artists = [];
  List<ArtistModel> _bufferArtists = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 16;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMoreArtists();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isLoading &&
        _hasMore &&
        !_isSearching) {
      _loadMoreArtists();
    }
  }

  void _onSearchSubmitted() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || query == '') {
      _resetAndLoad();
      return;
    }
    setState(() {
      _isSearching = true;
      _hasMore = false;
      _bufferArtists = [..._artists];
      _artists.clear();
    });

    try {
      final results = await artistsSearchFuture(query);
      setState(() {
        _artists.addAll(results);
      });
    } catch (e) {
      log("Error searching artists: $e");
    }
  }

  void _resetAndLoad() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _offset = _bufferArtists.isNotEmpty ? _bufferArtists.length : 0;
      _artists
        ..clear()
        ..addAll(_bufferArtists);
      _hasMore = true;
    });
    _bufferArtists.clear();
  }

  Future<void> _loadMoreArtists() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newArtists = await artistsFuture(offset: _offset, limit: _limit);
      setState(() {
        _artists.addAll(newArtists);
        _offset += newArtists.length;
        _hasMore = newArtists.length == _limit;
      });
    } catch (e) {
      log("Error loading artists: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Các nghệ sĩ')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nghệ sĩ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _resetAndLoad,
                ),
              ),
              onSubmitted: (_) => _onSearchSubmitted(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount:
                    _artists.length + (_isLoading && !_isSearching ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _artists.length) {
                    return ArtistCard(variant: 1, artist: _artists[index]);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
