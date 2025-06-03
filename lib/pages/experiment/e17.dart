import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/artist/song_list_tile.dart';
import 'package:memecloud/components/common/confirmation_dialog.dart';
import 'package:memecloud/components/miscs/data_inspector.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/song/mini_player.dart';

import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';

import 'package:memecloud/pages/song/list_song_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/miscs/expandable/html.dart';
import 'package:memecloud/pages/artist/album_artist_page.dart';

class ArtistPage17 extends StatefulWidget {
  final String artistAlias;

  const ArtistPage17({super.key, required this.artistAlias});

  @override
  State<ArtistPage17> createState() => _ArtistPage17State();
}

class _ArtistPage17State extends State<ArtistPage17> {
  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getArtistInfo(widget.artistAlias),
      onData: (context, data) => DataInspector(data!.toJson(only: false)),
    );
  }
}
