import 'package:flutter/material.dart';

/// Global locale notifier to update app language at runtime.
final ValueNotifier<Locale?> appLocaleNotifier = ValueNotifier<Locale?>(null);

/// Helper to map human-readable language names to locale codes.
Locale localeFromDisplayName(String displayName) {
  switch (displayName) {
    case 'Hindi':
      return const Locale('hi');
    case 'Punjabi':
      return const Locale('pa');
    case 'English':
    default:
      return const Locale('en');
  }
}

String displayNameFromLocale(Locale? locale) {
  final code = locale?.languageCode ?? 'en';
  switch (code) {
    case 'hi':
      return 'Hindi';
    case 'pa':
      return 'Punjabi';
    case 'en':
    default:
      return 'English';
  }
}

