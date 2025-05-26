import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

// Helper function to read the response stream
Future<Uint8List> _consolidateHttpClientResponseBytes(HttpClientResponse response) {
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
  static Future<void> uploadSongFromUrl(String url, String songId) async {
    final uri = Uri.parse(url);
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode != 200) {
      throw Exception('Tải thất bại từ $url (status: ${response.statusCode})');
    }

    // Read the response stream into bytes
    final bytes = await _consolidateHttpClientResponseBytes(response);

    final ref = FirebaseStorage.instance.ref().child('musics/$songId.mp3');
    final metadata = SettableMetadata(contentType: 'audio/mpeg');
    final uploadTask = ref.putData(bytes, metadata);

    await uploadTask;
  }

  static Future<String?> getSongUrl(String songId) async {
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
