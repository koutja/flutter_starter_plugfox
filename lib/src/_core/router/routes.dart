import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:starter/src/account/widget/about_app_dialog.dart';
import 'package:starter/src/account/widget/profile_screen.dart';
import 'package:starter/src/account/widget/settings_dialog.dart';
import 'package:starter/src/authentication/widget/signin_screen.dart';
import 'package:starter/src/authentication/widget/signup_screen.dart';
import 'package:starter/src/home/widget/home_screen.dart';

enum Routes with OctopusRoute {
  signin('signin', title: 'Sign-In'),
  signup('signup', title: 'Sign-Up'),
  home('home', title: 'Home'),
  profile('profile', title: 'Profile'),
  settingsDialog('settings-dialog', title: 'Settings'),
  aboutAppDialog('about-app-dialog', title: 'About Application')
  ;

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) =>
      switch (this) {
        Routes.signin => const SignInScreen(),
        Routes.signup => const SignUpScreen(),
        Routes.home => const HomeScreen(),
        Routes.profile => const ProfileScreen(),
        Routes.settingsDialog => const SettingsDialog(),
        Routes.aboutAppDialog => const AboutApplicationDialog(),
      };

  /*
  @override
  Page<Object?> pageBuilder(BuildContext context, OctopusNode node) =>
      node.name.endsWith('-custom')
          ? CustomUserPage()
          : super.pageBuilder(context, node);
  */
}
