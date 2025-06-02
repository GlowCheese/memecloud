import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/common/confirmation_dialog.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/song/mini_player.dart';
import 'package:memecloud/components/miscs/expandable/html.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/pages/song/list_song_page.dart';
import 'package:memecloud/pages/artist/album_artist_page.dart';

class ArtistPage extends StatefulWidget {
  final String artistAlias;
  const ArtistPage({super.key, required this.artistAlias});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late final Future<ArtistModel?> _artistFuture;
  final _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _artistFuture = getIt<ApiKit>().getArtistInfo(widget.artistAlias);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 200;
    if (shouldShow != _showTitle) setState(() => _showTitle = shouldShow);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: defaultFutureBuilder(
        future: _artistFuture,
        onNull:
            (_) => const Center(
              child: Text(
                'Không tìm thấy thông tin nghệ sĩ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
        onData: (_, artist) => _buildContent(artist!),
      ),
    );
  }

  Widget _buildContent(ArtistModel artist) {
    final songs = artist.sections![0].items.cast<SongModel>().toList();
    final playlists = artist.sections![1].items.cast<PlaylistModel>().toList();
    final albums = artist.sections![2].items.cast<PlaylistModel>().toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(artist),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (songs.isNotEmpty) ...[
                      _SongsSection(songs: songs),
                      const SizedBox(height: 32),
                      _buildDivider(),
                    ],
                    if (albums.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _AlbumsSection(title: 'Albums', albums: albums),
                      const SizedBox(height: 32),
                      _buildDivider(),
                    ],
                    if (playlists.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _AlbumsSection(title: 'Playlist', albums: playlists),
                      const SizedBox(height: 32),
                      _buildDivider(),
                    ],
                    const SizedBox(height: 24),
                    _ArtistInfo(artist: artist),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        MiniPlayer(floating: true),
      ],
    );
  }

  Widget _buildAppBar(ArtistModel artist) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                artist.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _ArtistHeader(artist: artist),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Theme.of(context).dividerColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _ArtistHeader extends StatelessWidget {
  final ArtistModel artist;
  const _ArtistHeader({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(context),
        _buildBackButton(context),
        _buildArtistInfo(context),
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(artist.thumbnailUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  Widget _buildArtistInfo(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artist.name,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FollowersCount(artistId: artist.id),
                  const SizedBox(height: 12),
                  _FollowButton(artistId: artist.id),
                ],
              ),
              _PlayControls(artist: artist),
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowersCount extends StatelessWidget {
  final String artistId;
  const _FollowersCount({required this.artistId});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getArtistFollowersCount(artistId),
      onData:
          (_, count) => Text(
            '${_formatNumber(count)} người theo dõi',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}

class _PlayControls extends StatelessWidget {
  final ArtistModel artist;
  const _PlayControls({required this.artist});

  @override
  Widget build(BuildContext context) {
    final songs = artist.sections![0].items.cast<SongModel>().toList();

    return Row(
      children: [
        _buildButton(Icons.shuffle, () => _playShuffle(context, songs), true),
        const SizedBox(width: 12),
        _buildButton(
          Icons.play_arrow,
          () => _playNormal(context, songs),
          false,
        ),
      ],
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onPressed, bool isSecondary) {
    return Builder(
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color:
                  isSecondary
                      ? Colors.white.withOpacity(0.2)
                      : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              border:
                  isSecondary
                      ? Border.all(color: Colors.white.withOpacity(0.3))
                      : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, size: 28),
              color:
                  isSecondary
                      ? Colors.white
                      : Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.all(12),
            ),
          ),
    );
  }

  Future<void> _playNormal(BuildContext context, List<SongModel> songs) async {
    final player = getIt<SongPlayerCubit>();
    if (player.shuffleMode) await player.toggleShuffleMode();
    await player.loadAndPlay(context, songs[0], songList: songs);
  }

  Future<void> _playShuffle(BuildContext context, List<SongModel> songs) async {
    final player = getIt<SongPlayerCubit>();
    if (!player.shuffleMode) await player.toggleShuffleMode();
    await player.loadAndPlay(context, songs[0], songList: songs);
  }
}

class _FollowButton extends StatefulWidget {
  final String artistId;
  const _FollowButton({required this.artistId});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool? isFollowing;

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
  }

  Future<void> _loadFollowStatus() async {
    final following = await getIt<ApiKit>().isFollowingArtist(widget.artistId);
    if (mounted) setState(() => isFollowing = following);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 140,
      decoration: BoxDecoration(
        color:
            isFollowing == true
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isFollowing == null ? null : _handleTap,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isFollowing == null) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFollowing! ? Icons.check : Icons.add,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            isFollowing! ? 'Đã theo dõi' : 'Theo dõi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTap() async {
    if (!isFollowing!) {
      await _follow();
    } else {
      await _showUnfollowDialog();
    }
  }

  Future<void> _follow() async {
    unawaited(getIt<ApiKit>().toggleFollowArtist(widget.artistId));
    setState(() => isFollowing = true);
  }

  Future<void> _showUnfollowDialog() async {
    final shouldUnfollow = await ConfirmationDialog.show(
      context: context,
      title: 'Hủy theo dõi',
      message: 'Bạn có chắc chắn muốn hủy theo dõi nghệ sĩ này?',
      confirmText: 'Hủy theo dõi',
      cancelText: 'Không',
    );

    if (shouldUnfollow == true && mounted) {
      unawaited(getIt<ApiKit>().toggleFollowArtist(widget.artistId));
      setState(() => isFollowing = false);
    }
  }
}

class _ArtistInfo extends StatelessWidget {
  final ArtistModel artist;
  const _ArtistInfo({required this.artist});

  @override
  Widget build(BuildContext context) {
    final hasRealname = artist.realname?.isNotEmpty == true;
    final hasBio = artist.biography?.isNotEmpty == true;

    if (!hasRealname && !hasBio) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasRealname) ...[
          _buildSection(
            context,
            'Tên thật',
            Text(
              artist.realname!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          if (hasBio) const SizedBox(height: 24),
        ],
        if (hasBio)
          _buildSection(
            context,
            'Tiểu sử',
            ExpandableHtml(htmlText: artist.biography!),
          ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}

class _SongsSection extends StatelessWidget {
  final List<SongModel> songs;
  const _SongsSection({required this.songs});

  @override
  Widget build(BuildContext context) {
    final displaySongs = songs.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displaySongs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder:
              (_, index) => SongCard(
                variant: 1,
                song: displaySongs[index],
                songList: songs,
              ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bài hát',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (songs.length > 5)
          TextButton.icon(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ListSongPage(songs: songs)),
                ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Xem tất cả'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }
}

class _AlbumsSection extends StatelessWidget {
  final String title;
  final List<PlaylistModel> albums;
  const _AlbumsSection({required this.title, required this.albums});

  @override
  Widget build(BuildContext context) {
    final displayAlbums = albums.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: displayAlbums.length,
          itemBuilder: (_, index) {
            return PlaylistCard(variant: 4, playlist: displayAlbums[index]);
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (albums.length > 4)
          TextButton.icon(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbumArtistPage(albums: albums),
                  ),
                ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Xem tất cả'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }
}
