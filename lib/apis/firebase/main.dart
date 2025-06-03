import 'dart:io';
import 'dart:async';
import 'dart:collection';
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
  final uploadQueue = Queue<Future Function()>();
  late final CancelableOperation uploadTask;

  FirebaseApi() {
    uploadTask = CancelableOperation.fromFuture(() async {
      while (true) {
        if (_isCancelled) break;
        if (uploadQueue.isEmpty) {
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }
        await uploadQueue.removeFirst()();
        await Future.delayed(const Duration(seconds: 150));
      }
    }(), onCancel: () => _isCancelled = true);
  }

  void cancel() {
    uploadTask.cancel();
  }

  void uploadSongFromUrl(String url, String songId) {
    uploadQueue.add(() async {
      final uri = Uri.parse(url);
      debugPrint('⬆️ Uploading $url');
      
      final request = await HttpClient().getUrl(uri);
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
