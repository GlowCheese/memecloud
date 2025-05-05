import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';

class E04 extends StatelessWidget {
  const E04({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getPlaylistInfo('ZOZ9FWW7'),
      onData: (context, data) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Text(data!.title, style: TextStyle(fontSize: 24)),
              Text(data.artistsNames!, style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(data.description!, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Column(
                children:
                    data.songs!.map((song) {
                      return ListTile(
                        leading: Image.network(song.thumbnailUrl),
                        title: Text(song.title),
                        subtitle: Text(song.artistsNames),
                        trailing: Text(song.duration.toString()),
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
