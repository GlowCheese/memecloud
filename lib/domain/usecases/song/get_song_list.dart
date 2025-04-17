import 'package:dartz/dartz.dart';
import 'package:memecloud/core/use_case.dart';
import 'package:memecloud/domain/repositories/song/song_repository.dart';
import 'package:memecloud/core/service_locator.dart';

class GetSongListUsecase extends UseCase {
  @override
  Future<Either> call(void params) async {
    return serviceLocator<SongRepository>().getSongList();
  }
}
