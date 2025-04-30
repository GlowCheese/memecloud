import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';

class E04 extends StatelessWidget {
  const E04({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getSongInfo('Z78BZ0D7'),
      onData: (context, data) => Text(data.toString())
    );
  }
}
