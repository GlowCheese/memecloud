// ignore_for_file: unused_import

import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/others/storage.dart';
import 'package:memecloud/apis/supabase/cache.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/apis/zingmp3/requester.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/search_result_model.dart';

void main() async {
  await dotenv.load();
  await setupLocator();
}
