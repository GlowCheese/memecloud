import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/miscs/data_inspector.dart';

class E04 extends StatelessWidget {
  const E04({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getTopArtists(count: 5),
      onData: (context, data) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final artist = data[index];
            final alias = artist.alias ?? 'Không có alias';

            // In alias ra console để debug
            print('Alias của artist $index: $alias');

            return ListTile(
              title: Text('Alias: $alias'),
              subtitle: DataInspector(
                value: artist,
              ), // Xem chi tiết object nếu cần
            );
          },
        );
      },
    );
  }
}
