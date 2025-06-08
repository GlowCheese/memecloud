import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Helper function to read the response stream
Future<Uint8List> _consolidateHttpClientResponseBytes(
  HttpClientResponse response,
) {
  final completer = Completer<Uint8List>();
  final contents = <int>[];
  response.listen(
    contents.addAll,
    onDone: () => completer.complete(Uint8List.fromList(contents)),
    onError: completer.completeError,
    cancelOnError: true,
  );
  return completer.future;
}

class FirebaseApi {
  bool _isCancelled = false;
  final _httpClient = HttpClient();
  late final CancelableOperation uploadTask;
  final uploadStack = <Future Function()>[];

  FirebaseApi() {
    uploadTask = CancelableOperation.fromFuture(() async {
      while (true) {
        if (_isCancelled) break;
        if (uploadStack.isNotEmpty) {
          try {
            await uploadStack.removeLast()();
          } catch (e, stackTrace) {
            log(
              'Failed to upload song to firebase',
              stackTrace: stackTrace,
              level: 1000,
            );
          }
          continue;
        }
        // if the stack has no element,
        // wait for 10 seconds until the next check
        await Future.delayed(const Duration(seconds: 10));
      }
    }(), onCancel: () => _isCancelled = true);
  }

  void cancel() {
    _httpClient.close();
    uploadTask.cancel();
  }

  void uploadSongFromUrl(String url, String songId) {
    uploadStack.add(() async {
      if (await getSongUrl(songId) != null) return;

      final uri = Uri.parse(url);
      debugPrint('⬆️ Uploading $url');

      final request = await _httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception(
          'Tải thất bại từ $url (status: ${response.statusCode})',
        );
      }

      // Read the response stream into bytes
      final bytes = await _consolidateHttpClientResponseBytes(response);

      final ref = FirebaseStorage.instance.ref().child('musics/$songId.mp3');
      final metadata = SettableMetadata(contentType: 'audio/mpeg');
      await ref.putData(bytes, metadata);
      debugPrint('✅ Upload success!');

      // prevent user from spam uploading too many songs
      await Future.delayed(const Duration(seconds: 20));
    });
  }

  Future<String?> getSongUrl(String songId) async {
    final ref = FirebaseStorage.instance.ref().child('musics/$songId.mp3');
    try {
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return null;
      }
      rethrow;
    }
  }
}
