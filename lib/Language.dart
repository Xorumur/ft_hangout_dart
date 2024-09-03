import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Contacts',
      'add_contact': 'Add Contact',
      'edit_contact': 'Edit Contact',
      'save': 'Save',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'phone': 'Phone',
      'Email': 'Email',
      'Age': 'Age',
      'Save': 'Save',
      'SelectColor': 'Select a color',
      'EditContact': 'Edit Contact',
      'typeMessage': 'Type a message',
      // Ajoutez d'autres clés et traductions ici
    },
    'fr': {
      'title': 'Contacts',
      'add_contact': 'Ajouter un contact',
      'edit_contact': 'Modifier un contact',
      'save': 'Enregistrer',
      'firstName': 'Prénom',
      'lastName': 'Nom de famille',
      'phone': 'Téléphone',
      'Email': 'Email',
      'Age': 'Âge',
      'Save': 'Enregistrer',
      'SelectColor': 'Sélectionner une couleur',
      'EditContact': 'Modifier le contact',
      'typeMessage': 'Tapez un message',
      // Ajoutez d'autres clés et traductions ici
    },
  };

  static Future<void> changeLanguage() async {
    if (_currentLanguage == 'en') {
      await setLanguage('fr');
    } else {
      await setLanguage('en');
    }
    print('Language changed to $_currentLanguage');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _currentLanguage);
  }

  static String _currentLanguage = 'en';

  static Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'en';
  }

  static String resolve(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }
}
