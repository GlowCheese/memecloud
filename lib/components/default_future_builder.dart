import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:memecloud/apis/connectivity.dart';

Widget defaultFutureBuilder<T>({
  required Future<T> future,
  required Widget Function(BuildContext context, T data) onData,
  Widget Function(BuildContext context, [dynamic error])? onError,
  T? initialData,
}) {
  return FutureBuilder(
    future: future,
    initialData: initialData,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      onError ??= (BuildContext context, [error]) {
        late String errorMsg;
        if (snapshot.hasError) {
          if (snapshot.error is ConnectionLoss) {
            errorMsg = snapshot.error!.toString();
          } else {
            errorMsg = 'Something went wrong! ${snapshot.error!}';
          }
        } else {
          errorMsg = 'Snapshot has no data!';
        }
        log(errorMsg, stackTrace: snapshot.stackTrace, level: 900);
        return Text(errorMsg);
      };

      if (snapshot.hasError || !snapshot.hasData) {
        return onError!(context, snapshot.error);
      }
      return onData(context, snapshot.data as T);
    },
  );
}
