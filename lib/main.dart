import 'package:flutter/material.dart';
import 'ContactListPage.dart';
import 'AddContactPage.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Contact Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Configuration des routes de l'application
      initialRoute: '/',
      routes: {
        '/': (context) => const ContactListPage(), // Page d'accueil qui affiche les contacts
        '/addContact': (context) => const AddContactPage(), // Page pour ajouter un contact
      },
    );
  }
}
