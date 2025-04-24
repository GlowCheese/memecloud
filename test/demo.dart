import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memecloud/apis/supabase/cache.dart';
import 'package:memecloud/core/getit.dart';

void main() async {
  await dotenv.load();
  await setupLocator();

  print(await getIt<SupabaseCacheApi>().getSongsForHome());
}