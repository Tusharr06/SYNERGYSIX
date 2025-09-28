

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agro_stick/l10n/locale_notifier.dart'; 
import 'package:flutter/material.dart';

class LanguageService {
  static Future<void> initializeAppLanguage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is logged in, load their saved language preference
        await _loadUserLanguage(user.uid);
      } else {
        // No user logged in, default to English
        appLocaleNotifier.value = const Locale('en');
      }
    } catch (e) {
      // If there's an error loading language, default to English
      appLocaleNotifier.value = const Locale('en');
      print('Error loading app language: $e');
    }
  }

  static Future<void> _loadUserLanguage(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data();
        final savedLanguage = data?['language'] ?? 'English';
        final locale = localeFromDisplayName(savedLanguage);
        appLocaleNotifier.value = locale;
        print('Loaded user language: $savedLanguage -> $locale');
      } else {
        // No saved language, default to English
        appLocaleNotifier.value = const Locale('en');
      }
    } catch (e) {
      print('Error loading user language: $e');
      appLocaleNotifier.value = const Locale('en');
    }
  }

  static Future<void> updateUserLanguage(String userId, String language) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'language': language,
      }, SetOptions(merge: true));
      
      // Apply the language change immediately
      appLocaleNotifier.value = localeFromDisplayName(language);
      print('Updated user language: $language');
    } catch (e) {
      print('Error updating user language: $e');
    }
  }
}