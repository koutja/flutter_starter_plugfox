import 'package:flutter/widgets.dart';
import 'package:l10n/gen/app_l10n.dart' as generated;
import 'package:meta/meta.dart';

part 'iso_langs.dart';

/// Localization.
final class Localization {
  Localization._(this.locale);

  final Locale locale;

  /// Localization delegate.
  static const LocalizationsDelegate<generated.AppL10n> delegate =
      _LocalizationView(
        generated.AppL10n.delegate,
      );

  /// Current localization instance.
  static generated.AppL10n get current => _current;
  static late generated.AppL10n _current;

  /// Get localization instance for the widget structure.
  static generated.AppL10n of(BuildContext context) =>
      switch (Localizations.of<generated.AppL10n>(context, generated.AppL10n)) {
        final generated.AppL10n localization => localization,
        _ => throw ArgumentError(
          'Out of scope, not found inherited widget '
              'a Localization of the exact type',
          'out_of_scope',
        ),
      };

  /// Get language by code.
  static ({String name, String nativeName})? getLanguageByCode(String code) =>
      switch (_isoLangs[code]) {
        final (String, String) lang => (name: lang.$1, nativeName: lang.$2),
        _ => null,
      };

  /// Get supported locales.
  static List<Locale> get supportedLocales =>
      generated.AppL10n.supportedLocales;
}

@immutable
final class _LocalizationView extends LocalizationsDelegate<generated.AppL10n> {
  @literal
  const _LocalizationView(
    LocalizationsDelegate<generated.AppL10n> delegate,
  ) : _delegate = delegate;

  final LocalizationsDelegate<generated.AppL10n> _delegate;

  @override
  bool isSupported(Locale locale) => _delegate.isSupported(locale);

  @override
  Future<generated.AppL10n> load(Locale locale) => _delegate
      .load(locale)
      .then<generated.AppL10n>(
        (localization) =>
            Localization._current = generated.lookupAppL10n(locale),
      );

  @override
  bool shouldReload(covariant _LocalizationView old) =>
      _delegate.shouldReload(old._delegate);
}
