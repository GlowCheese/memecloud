import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/data_inspector.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class E04 extends StatelessWidget {
  const E04({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getArtistInfo('Son-Tung-M-TP'),
      onData: (context, data) {
        return SingleChildScrollView(
          child: DataInspector(value: data?.toJson()),
        );
      },
    );
  }
}
