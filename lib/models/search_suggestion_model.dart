import 'package:memecloud/apis/zingmp3/endpoints.dart';

class SearchSuggestionModel {
  final List<String>? keywords;
  // final List<MusicModel>? suggestions;

  SearchSuggestionModel._({
    required this.keywords,
    // required this.suggestions
  });

  static Future<SearchSuggestionModel> fromList<T>(
    List<Map<String, dynamic>> items,
  ) async {
    if (T != ZingMp3Api) {
      throw UnsupportedError('Unable to parse search suggestion for type $T');
    }

    List<String>? keywords;
    // List<MusicModel>? suggestions;

    for (Map<String, dynamic> item in items) {
      if (item.containsKey('keywords')) {
        keywords = keywords ?? [];
        keywords.addAll(
          (item['keywords'] as List)
              .map((e) => (e as Map)['keyword'] as String)
              .toList(),
        );
      }
      // if (item.containsKey('suggestions')) {
      //   suggestions = suggestions ?? [];
      //   for (Map<String, dynamic> e in item['suggestions']) {
      //     switch (e['type']) {
      //       case 1:
      //         suggestions.add(await SongModel.fromJson<T>(e));
      //         break;
      //       case 3:
      //         suggestions.add(await PlaylistModel.fromJson<T>(e));
      //         break;
      //       case 4:
      //         suggestions.add(await ArtistModel.fromJson<T>(e));
      //         break;
      //       default:
      //         break;
      //     }
      //   }
      // }
    }

    return SearchSuggestionModel._(
      keywords: keywords,
      // suggestions: suggestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keywords': keywords,
      // 'suggestions': suggestions?.map((e) => toJson()).toList(),
    };
  }
}
