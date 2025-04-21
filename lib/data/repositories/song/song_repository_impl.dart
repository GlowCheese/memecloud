import 'package:dartz/dartz.dart';
import 'package:memecloud/data/sources/song/song_service.dart';
import 'package:memecloud/domain/repositories/song/song_repository.dart';
import 'package:memecloud/core/service_locator.dart';

class SongRepositoryImpl extends SongRepository {
  @override
  Future<Either> getSongList() async{
    return await serviceLocator<SongService>().fetchSongList();
  }
  
}