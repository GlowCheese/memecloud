import 'package:get_it/get_it.dart';
import 'package:memecloud/domain/usecases/auth/sign_up.dart';
import 'package:memecloud/domain/usecases/auth/sign_in.dart';
import 'package:memecloud/domain/usecases/auth/sign_out.dart';
import 'package:memecloud/data/sources/auth/auth_supabase_service.dart';
import 'package:memecloud/domain/repositories/auth/auth_repository.dart';
import 'package:memecloud/data/repositories/auth/auth_repository_impl.dart';
import 'package:memecloud/data/repositories/song/song_supabase_impl.dart';
import 'package:memecloud/data/sources/song/song_service.dart';
import 'package:memecloud/domain/repositories/song/song_repository.dart';
import 'package:memecloud/domain/usecases/song/get_song_list.dart';
import 'package:memecloud/presentation/view/song_player/bloc/song_player_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  serviceLocator.registerSingleton<SupabaseClient>(Supabase.instance.client);
  serviceLocator.registerSingleton<AuthSupabaseService>(AuthSupabaseService());
  serviceLocator.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  serviceLocator.registerSingleton<SignInUseCase>(SignInUseCase());
  serviceLocator.registerSingleton<SignupUseCase>(SignupUseCase());
  serviceLocator.registerSingleton<SignOutUseCase>(SignOutUseCase());

  serviceLocator.registerSingleton<SongRepository>(SongSupabaseImpl());
  serviceLocator.registerSingleton<SongService>(SongSupabaseService());
  serviceLocator.registerSingleton<GetSongListUsecase>(GetSongListUsecase());

  serviceLocator.registerSingleton<SongPlayerCubit>(SongPlayerCubit());
}
