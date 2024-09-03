// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart'; // Importer le package intl
// import 'database_service.dart';
// import 'contact.dart';
// import 'ColorSelectionPage.dart';
// import 'EditContactPage.dart';
// import 'AddContactPage.dart';
// import 'Language.dart';

// class ContactListPage extends StatefulWidget {
//   const ContactListPage({super.key});

//   @override
//   _ContactListPageState createState() => _ContactListPageState();
// }

// class _ContactListPageState extends State<ContactListPage> with WidgetsBindingObserver {
//   List<Contact> contacts = [];
//   Color _appBarColor = Colors.blue; // Couleur par défaut de l'AppBar
//   String? _lastPausedTime; // Variable pour stocker l'heure à laquelle l'application a été mise en pause

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // Ajouter l'observateur
//     _loadLastPausedTime(); // Charger l'heure à laquelle l'application a été mise en pause
//     _loadAppBarColor();  // Charger la couleur de l'AppBar lors de l'initialisation
//     _loadContacts();  // Charger les contacts lors de l'initialisation de la page
//   }


//   // Méthode pour surveiller les changements d'état de l'application
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     if (state == AppLifecycleState.paused) {
//       _saveLastPausedTime(); // Sauvegarder l'heure lorsque l'application est mise en pause
//     } else if (state == AppLifecycleState.resumed) {
//       _loadLastPausedTime(); // Recharger l'heure lorsque l'application revient au premier plan
//     }
//   }

//   Future<void> _saveLastPausedTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     final now = DateTime.now().toIso8601String();
//     await prefs.setString('lastPausedTime', now);
//     setState(() {
//       _lastPausedTime = now;
//     });
//   }

//   Future<void> _loadLastPausedTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastPausedTimeString = prefs.getString('lastPausedTime');
//     if (lastPausedTimeString != null) {
//       final lastPausedTime = DateTime.parse(lastPausedTimeString);
//       setState(() {
//         _lastPausedTime = DateFormat('HH:mm, d MMM y').format(lastPausedTime);
//       });
//     }
//   }
  
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this); // Retirer l'observateur
//     super.dispose();
//   }

//   Future<void> _loadAppBarColor() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _appBarColor = Color(prefs.getInt('appBarColor') ?? Colors.blue.value);
//     });
//   }

//   Future<void> _setAppBarColor(Color color) async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _appBarColor = color;
//     });
//     await prefs.setInt('appBarColor', color.value);
//   }

//   Future<void> _loadContacts() async {
//     final loadedContacts = await DatabaseService.instance.readAllContacts();
//     setState(() {
//       contacts = loadedContacts;
//     });
//   }

//   Future<void> _addContact(Contact contact) async {
//     await DatabaseService.instance.createContact(contact);
//     _loadContacts();  // Recharger les contacts après ajout
//   }

//   Future<void> _updateContact(Contact updatedContact) async {
//     await DatabaseService.instance.updateContact(updatedContact);
//     _loadContacts();  // Recharger les contacts après modification
//   }

//   Future<void> _deleteContact(int id) async {
//     await DatabaseService.instance.deleteContact(id);
//     _loadContacts();  // Recharger les contacts après suppression
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(Language.resolve("title")),
//             if (_lastPausedTime != null)
//               Text(
//                 'Paused at: $_lastPausedTime',
//                 style: TextStyle(fontSize: 14.0),
//               ),
//           ],
//         ),
//         backgroundColor: _appBarColor, // Utilisation de la couleur sélectionnée
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () async {
//               // Naviguer vers la page d'ajout de contact
//               final newContact = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AddContactPage(),
//                 ),
//               );

//               if (newContact != null) {
//                 _addContact(newContact);
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.color_lens),
//             onPressed: () async {
//               // Naviguer vers la page de sélection de couleur
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ColorSelectionPage(
//                     onColorSelected: (color) {
//                       _setAppBarColor(color);
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon : const Icon(Icons.language),
//             onPressed: () async {
//               await Language.changeLanguage(); // Change la langue
//               setState(() {}); // Force la reconstruction de la page pour mettre à jour l'affichage
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: contacts.length,
//         itemBuilder: (context, index) {
//           final contact = contacts[index];
//           final fullName = '${contact.firstName} ${contact.lastName}';

//           return Card(
//             margin: const EdgeInsets.all(8.0),
//             child: ListTile(
//               leading: const Icon(Icons.person),
//               title: Text(fullName),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('${Language.resolve("phone")}: ${contact.phone}'),
//                   Text('Email: ${contact.email}'),
//                   Text('Age: ${contact.age}'),
//                 ],
//               ),
//               onTap: () async {
//                 // Naviguer vers la page d'édition pour modifier le contact
//                 final updatedContact = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditContactPage(contact: contact),
//                   ),
//                 );

//                 // Si un contact mis à jour a été retourné, mettre à jour la base de données
//                 if (updatedContact != null) {
//                   _updateContact(updatedContact);
//                 }
//               },
//               onLongPress: () {
//                 // Supprimer le contact sur un appui long
//                 _deleteContact(contact.id!);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart'; // Importer le package url_launcher
// import 'database_service.dart';
// import 'contact.dart';
// import 'ColorSelectionPage.dart';
// import 'EditContactPage.dart';
// import 'AddContactPage.dart';
// import 'Language.dart';

// class ContactListPage extends StatefulWidget {
//   const ContactListPage({super.key});

//   @override
//   _ContactListPageState createState() => _ContactListPageState();
// }

// class _ContactListPageState extends State<ContactListPage> with WidgetsBindingObserver {
//   List<Contact> contacts = [];
//   Color _appBarColor = Colors.blue; // Couleur par défaut de l'AppBar
//   String? _lastPausedTime; // Variable pour stocker l'heure à laquelle l'application a été mise en pause

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // Ajouter l'observateur
//     _loadLastPausedTime(); // Charger l'heure à laquelle l'application a été mise en pause
//     _loadAppBarColor();  // Charger la couleur de l'AppBar lors de l'initialisation
//     _loadContacts();  // Charger les contacts lors de l'initialisation de la page
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this); // Retirer l'observateur
//     super.dispose();
//   }

//   // Méthode pour surveiller les changements d'état de l'application
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     if (state == AppLifecycleState.paused) {
//       _saveLastPausedTime(); // Sauvegarder l'heure lorsque l'application est mise en pause
//     } else if (state == AppLifecycleState.resumed) {
//       _loadLastPausedTime(); // Recharger l'heure lorsque l'application revient au premier plan
//     }
//   }

//   Future<void> _saveLastPausedTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     final now = DateTime.now().toIso8601String();
//     await prefs.setString('lastPausedTime', now);
//     setState(() {
//       _lastPausedTime = now;
//     });
//   }

//   Future<void> _loadLastPausedTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastPausedTimeString = prefs.getString('lastPausedTime');
//     if (lastPausedTimeString != null) {
//       final lastPausedTime = DateTime.parse(lastPausedTimeString);
//       setState(() {
//         _lastPausedTime = DateFormat('HH:mm, d MMM y').format(lastPausedTime);
//       });
//     }
//   }

//   Future<void> _loadAppBarColor() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _appBarColor = Color(prefs.getInt('appBarColor') ?? Colors.blue.value);
//     });
//   }

//   Future<void> _setAppBarColor(Color color) async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _appBarColor = color;
//     });
//     await prefs.setInt('appBarColor', color.value);
//   }

//   Future<void> _loadContacts() async {
//     final loadedContacts = await DatabaseService.instance.readAllContacts();
//     setState(() {
//       contacts = loadedContacts;
//     });
//   }

//   Future<void> _addContact(Contact contact) async {
//     await DatabaseService.instance.createContact(contact);
//     _loadContacts();  // Recharger les contacts après ajout
//   }

//   Future<void> _updateContact(Contact updatedContact) async {
//     await DatabaseService.instance.updateContact(updatedContact);
//     _loadContacts();  // Recharger les contacts après modification
//   }

//   Future<void> _deleteContact(int id) async {
//     await DatabaseService.instance.deleteContact(id);
//     _loadContacts();  // Recharger les contacts après suppression
//   }

//   Future<void> _sendSMS(String phoneNumber, String message) async {
//     final Uri smsUri = Uri(
//       scheme: 'sms',
//       path: phoneNumber,
//       queryParameters: <String, String>{
//         'body': message,
//       },
//     );

//     if (await canLaunchUrl(smsUri)) {
//       await launchUrl(smsUri);
//     } else {
//       print('Could not launch $smsUri');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(Language.resolve("title")),
//             if (_lastPausedTime != null)
//               Text(
//                 'Paused at: $_lastPausedTime',
//                 style: TextStyle(fontSize: 14.0),
//               ),
//           ],
//         ),
//         backgroundColor: _appBarColor, // Utilisation de la couleur sélectionnée
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () async {
//               // Naviguer vers la page d'ajout de contact
//               final newContact = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AddContactPage(),
//                 ),
//               );

//               if (newContact != null) {
//                 _addContact(newContact);
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.color_lens),
//             onPressed: () async {
//               // Naviguer vers la page de sélection de couleur
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ColorSelectionPage(
//                     onColorSelected: (color) {
//                       _setAppBarColor(color);
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon : const Icon(Icons.language),
//             onPressed: () async {
//               await Language.changeLanguage(); // Change la langue
//               setState(() {}); // Force la reconstruction de la page pour mettre à jour l'affichage
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: contacts.length,
//         itemBuilder: (context, index) {
//           final contact = contacts[index];
//           final fullName = '${contact.firstName} ${contact.lastName}';

//           return Card(
//             margin: const EdgeInsets.all(8.0),
//             child: ListTile(
//               leading: const Icon(Icons.person),
//               title: Text(fullName),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('${Language.resolve("phone")}: ${contact.phone}'),
//                   Text('Email: ${contact.email}'),
//                   Text('Age: ${contact.age}'),
//                 ],
//               ),
//               onTap: () async {
//                 // Naviguer vers la page d'édition pour modifier le contact
//                 final updatedContact = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditContactPage(contact: contact),
//                   ),
//                 );

//                 // Si un contact mis à jour a été retourné, mettre à jour la base de données
//                 if (updatedContact != null) {
//                   _updateContact(updatedContact);
//                 }
//               },
//               onLongPress: () {
//                 // Supprimer le contact sur un appui long
//                 _deleteContact(contact.id!);
//               },
//               trailing: IconButton(
//                 icon: const Icon(Icons.message),
//                 onPressed: () {
//                   // Envoi d'un SMS au contact
//                   _sendSMS(contact.phone, 'Hello, this is a test message.');
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Importer le package intl
import 'package:url_launcher/url_launcher.dart'; // Importer le package url_launcher
import 'package:telephony/telephony.dart'; // Importer le package telephony
import 'database_service.dart';
import 'contact.dart';
import 'ColorSelectionPage.dart';
import 'EditContactPage.dart';
import 'AddContactPage.dart';
import 'Language.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> with WidgetsBindingObserver {
  List<Contact> contacts = [];
  Color _appBarColor = Colors.blue; // Couleur par défaut de l'AppBar
  String? _lastPausedTime; // Variable pour stocker l'heure à laquelle l'application a été mise en pause
  final Telephony telephony = Telephony.instance; // Instance de Telephony

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Ajouter l'observateur
    _loadLastPausedTime(); // Charger l'heure à laquelle l'application a été mise en pause
    _loadAppBarColor();  // Charger la couleur de l'AppBar lors de l'initialisation
    _loadContacts();  // Charger les contacts lors de l'initialisation de la page
    _requestSmsPermissions(); // Demander les permissions SMS
  }

  Future<void> _requestSmsPermissions() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted == null || !permissionsGranted) {
      print("Permissions SMS refusées.");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Retirer l'observateur
    super.dispose();
  }

  // Méthode pour surveiller les changements d'état de l'application
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _saveLastPausedTime(); // Sauvegarder l'heure lorsque l'application est mise en pause
    } else if (state == AppLifecycleState.resumed) {
      _loadLastPausedTime(); // Recharger l'heure lorsque l'application revient au premier plan
    }
  }

  Future<void> _saveLastPausedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString('lastPausedTime', now);
    setState(() {
      _lastPausedTime = now;
    });
  }

  Future<void> _loadLastPausedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPausedTimeString = prefs.getString('lastPausedTime');
    if (lastPausedTimeString != null) {
      final lastPausedTime = DateTime.parse(lastPausedTimeString);
      setState(() {
        _lastPausedTime = DateFormat('HH:mm, d MMM y').format(lastPausedTime);
      });
    }
  }

  Future<void> _loadAppBarColor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appBarColor = Color(prefs.getInt('appBarColor') ?? Colors.blue.value);
    });
  }

  Future<void> _setAppBarColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appBarColor = color;
    });
    await prefs.setInt('appBarColor', color.value);
  }

  Future<void> _loadContacts() async {
    final loadedContacts = await DatabaseService.instance.readAllContacts();
    setState(() {
      contacts = loadedContacts;
    });
  }

  Future<void> _addContact(Contact contact) async {
    await DatabaseService.instance.createContact(contact);
    _loadContacts();  // Recharger les contacts après ajout
  }

  Future<void> _updateContact(Contact updatedContact) async {
    await DatabaseService.instance.updateContact(updatedContact);
    _loadContacts();  // Recharger les contacts après modification
  }

  Future<void> _deleteContact(int id) async {
    await DatabaseService.instance.deleteContact(id);
    _loadContacts();  // Recharger les contacts après suppression
  }

  // Méthode utilisant url_launcher
  Future<void> _sendSMSWithUrlLauncher(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print('Could not launch $smsUri');
    }
  }

  // Méthode utilisant telephony
  Future<void> _sendSMSWithTelephony(String message, String recipient) async {
    try {
      await telephony.sendSms(
        to: recipient,
        message: message,
      );
      print("SMS envoyé avec succès à $recipient");
    } catch (error) {
      print("Échec de l'envoi du SMS : $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Language.resolve("title")),
            if (_lastPausedTime != null)
              Text(
                'Paused at: $_lastPausedTime',
                style: TextStyle(fontSize: 14.0),
              ),
          ],
        ),
        backgroundColor: _appBarColor, // Utilisation de la couleur sélectionnée
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Naviguer vers la page d'ajout de contact
              final newContact = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddContactPage(),
                ),
              );

              if (newContact != null) {
                _addContact(newContact);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () async {
              // Naviguer vers la page de sélection de couleur
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ColorSelectionPage(
                    onColorSelected: (color) {
                      _setAppBarColor(color);
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon : const Icon(Icons.language),
            onPressed: () async {
              await Language.changeLanguage(); // Change la langue
              setState(() {}); // Force la reconstruction de la page pour mettre à jour l'affichage
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final fullName = '${contact.firstName} ${contact.lastName}';

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${Language.resolve("phone")}: ${contact.phone}'),
                  Text('Email: ${contact.email}'),
                  Text('Age: ${contact.age}'),
                ],
              ),
              onTap: () async {
                // Naviguer vers la page d'édition pour modifier le contact
                final updatedContact = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditContactPage(contact: contact),
                  ),
                );

                // Si un contact mis à jour a été retourné, mettre à jour la base de données
                if (updatedContact != null) {
                  _updateContact(updatedContact);
                }
              },
              onLongPress: () {
                // Supprimer le contact sur un appui long
                _deleteContact(contact.id!);
              },
              trailing: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      // Envoi d'un SMS au contact avec url_launcher
                      _sendSMSWithUrlLauncher(contact.phone, 'Hello, this is a test message.');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // Envoi d'un SMS au contact avec telephony
                      _sendSMSWithTelephony('Hello, this is a test message.', contact.phone);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
