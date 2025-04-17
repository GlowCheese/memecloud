import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/service_locator.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:memecloud/domain/usecases/auth/sign_out.dart';

AppBar defaultAppBar(BuildContext context, {required String title}) {
  var adaptiveTheme = AdaptiveTheme.of(context);
  return AppBar(
    backgroundColor: Colors.transparent,
    title: Text(
      title,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    leadingWidth: 60,
    leading: Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 30),
      child: SvgPicture.asset(
        'assets/icons/rocket-light.svg',
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    ),
    actions: [
      GestureDetector(
        onTap: () => adaptiveTheme.toggleThemeMode(useSystem: false),
        child: Icon(
          adaptiveTheme.mode.isDark
              ? Icons.light_mode
              : Icons.dark_mode_outlined,
          color: Colors.white,
        ),
      ),
      SizedBox(width: 4),
      IconButton(
        color: Colors.white,
        onPressed: () {},
        icon: const Icon(Icons.notifications),
      ),
      SizedBox(width: 4),
      GestureDetector(
        onTap: () async {
          context.go('/startview');
          await serviceLocator<SignOutUseCase>().call();
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuAqi5s1FOI-T3qoE_2HD1avj69-gvq2cvIw&s',
          ),
        ),
      ),
      SizedBox(width: 12),
    ],
  );
}
