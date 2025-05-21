import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:memecloud/apis/others/connectivity.dart';

Widget defaultFutureBuilder<T>({
  required Future<T> future,
  Widget onWaiting = const Center(child: CircularProgressIndicator()),
  required Widget Function(BuildContext context, T data) onData,
  Widget Function(BuildContext context)? onNull,
  Widget Function(BuildContext context, dynamic error)? onError,
  T? initialData,
}) {
  return FutureBuilder(
    future: future,
    initialData: initialData,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return onWaiting;
      }

      onError ??= (BuildContext context, error) {
        late String errorMsg;
        if (snapshot.error is ConnectionLoss) {
          errorMsg = snapshot.error!.toString();
        } else {
          errorMsg = 'Something went wrong! ${snapshot.error!}';
        }
        log(errorMsg, stackTrace: snapshot.stackTrace, level: 900);
        return Text(errorMsg);
      };

      onNull ??= (BuildContext context) {
        return Text('Snapshot has no data!');
      };

      if (snapshot.hasError) {
        return onError!(context, snapshot.error);
      }
      if (!snapshot.hasData) {
        return onNull!(context);
      }
      return onData(context, snapshot.data as T);
    },
  );
}
