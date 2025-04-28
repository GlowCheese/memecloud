import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';

class E04 extends StatelessWidget {
  const E04({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<ApiKit>().getSongInfo('Z78BZ0D7'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Failed to get song info!');
        }

        final res = snapshot.data!;
        return res.fold((l) => Text(l), (r) => Text(r.toString()));
      },
    );
  }
}
