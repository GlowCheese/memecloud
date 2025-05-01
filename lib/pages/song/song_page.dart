import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/components/grad_background.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/components/song/song_controller.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final playerCubit = getIt<SongPlayerCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      bloc: playerCubit,
      builder: (context, state) {
        if (state is! SongPlayerLoaded) {
          return SizedBox();
        }

        return getIt<ApiKit>().paletteColorsWidgetBuider(
          state.currentSong.thumbnailUrl,
          (paletteColors) {
            return GradBackground(
              color: paletteColors[1],
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
                          SongControllerView(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
        IconButton(
          onPressed: () {
            setState(() {
              song.setIsLiked(!song.isLiked!);
            });
          },
          icon: Icon(
            song.isLiked! ? Icons.favorite : Icons.favorite_outline_outlined,
            size: 30,
            color: song.isLiked! ? Colors.red.shade400 : Colors.white,
          ),
        ),
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
