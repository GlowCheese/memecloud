import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/core/noti_init.dart';
import 'package:memecloud/core/theme.dart';
import 'package:memecloud/routes/main.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memecloud/apis/others/events.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:memecloud/blocs/song_player/justaudio_init.dart';
import 'package:memecloud/stripe/service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await notiInit();
  await dotenv.load();
  await setupLocator();
  
  await justAudioInit();
  await Firebase.initializeApp();
  await stripeSetup();

  // Load user data if the user is logged in
  if (getIt<ApiKit>().currentSession() != null) {
    await getIt<SupabaseEvents>().loadUserData();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: MaterialTheme(
        GoogleFonts.bricolageGrotesqueTextTheme(),
      ).theme(MaterialTheme.lightScheme()),
      dark: MaterialTheme(
        GoogleFonts.bricolageGrotesqueTextTheme(),
      ).theme(MaterialTheme.darkScheme()),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          routerConfig: getRouter(),
        );
      },
    );
  }
}
