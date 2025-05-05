import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/components/song/song_lyric.dart';
import 'package:memecloud/components/song/like_button.dart';
import 'package:memecloud/components/song/song_controller.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class SongPage extends StatelessWidget {
  final playerCubit = getIt<SongPlayerCubit>();

  SongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      bloc: playerCubit,
      builder: (context, state) {
        if (state is! SongPlayerLoaded) {
          return SizedBox();
        }

        return GradBackground2(
          imageUrl: state.currentSong.thumbnailUrl,
          child: Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: const AppBarTheme(foregroundColor: Colors.white),
              textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),
            child: Scaffold(
              appBar: _appBar(context),
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 46),
                        _songCover(context, state.currentSong),
                        SizedBox(height: 30),
                        _songDetails(state.currentSong),
                        SizedBox(height: 20),
                        SongControllerView(song: state.currentSong),
                        SizedBox(height: 50),
                        _songLyric(state.currentSong),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _songLyric(SongModel song) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.brown.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      child: defaultFutureBuilder(
        future: getIt<ApiKit>().getSongLyric(song.id),
        onNull: (context) {
          return Center(child: Text('This song currently has no lyric!'));
        },
        onData: (context, data) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Lời bài hát',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push('/song_lyric');
                      },
                      icon: Icon(Icons.open_in_full),
                    ),
                  ],
                ),
              ),
              Expanded(child: SongLyricWidget(lyric: data!, largeText: false)),
            ],
          );
        },
      ),
    );
  }

  Row _songDetails(SongModel song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                song.artistsNames,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        SongLikeButton(song: song),
      ],
    );
  }

  Widget _songCover(BuildContext context, SongModel song) {
    double size = MediaQuery.of(context).size.width - 64;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(song.thumbnailUrl),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text('Now Playing'),
      leading: BackButton(
        onPressed: () {
          try {
            context.pop();
          } catch (e) {
            context.go('/404');
          }
        },
      ),
    );
  }
}
