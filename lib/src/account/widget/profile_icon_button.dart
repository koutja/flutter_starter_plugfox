import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l10n/l10n.dart';
import 'package:octopus/octopus.dart';
import 'package:starter/src/_core/router/routes.dart';

/// {@template profile_icon_button}
/// ProfileIconButton widget
/// {@endtemplate}
class ProfileIconButton extends StatelessWidget {
  /// {@macro profile_icon_button}
  const ProfileIconButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.person),
    tooltip: Localization.of(context).profileButton,
    onPressed: () {
      Octopus.maybeOf(context)?.setState(
        (state) => state
          ..removeByName(Routes.profile.name)
          ..add(Routes.profile.node()),
      );
      HapticFeedback.mediumImpact().ignore();
    },
  );
}
