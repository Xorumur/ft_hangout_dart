import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ft_hangout/ChatPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_service.dart';
import 'contact.dart';
import 'ColorSelectionPage.dart';
import 'EditContactPage.dart';
import 'AddContactPage.dart';
import 'Language.dart';
import 'SmsListener.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> with WidgetsBindingObserver {
  List<Contact> contacts = [];
  Color _appBarColor = Colors.blue; // Couleur par défaut de l'AppBar
  String? _lastPausedTime;

  static const platform = MethodChannel('sms_sender'); // MethodChannel pour l'envoi de SMS et appels natifs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _loadLastPausedTime();
    _loadAppBarColor();
    _loadContacts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _saveLastPausedTime();
    } else if (state == AppLifecycleState.resumed) {
      _loadLastPausedTime();
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
    _loadContacts();
  }

  Future<void> _updateContact(Contact updatedContact) async {
    await DatabaseService.instance.updateContact(updatedContact);
    _loadContacts();
  }

  Future<void> _deleteContact(int id) async {
    await DatabaseService.instance.deleteContact(id);
    _loadContacts();
  }

  // Méthode pour appeler un contact en utilisant la fonction native
  Future<void> _callContact(String phoneNumber) async {
    try {
      await platform.invokeMethod('makeCall', {'phoneNumber': phoneNumber});
    } on PlatformException catch (e) {
      print("Failed to make a call: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmsListener>(
      builder: (context, smsListener, child) {
        _loadContacts();
        _loadAppBarColor();
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Language.resolve("title")),
                if (_lastPausedTime != null)
                  Text(
                    '${Language.resolve('Pause')}: $_lastPausedTime',
                    style: TextStyle(fontSize: 14.0),
                  ),
              ],
            ),
            backgroundColor: _appBarColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
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
                icon: const Icon(Icons.language),
                onPressed: () async {
                  await Language.changeLanguage();
                  setState(() {});
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
                    final updatedContact = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditContactPage(contact: contact),
                      ),
                    );

                    if (updatedContact != null) {
                      _updateContact(updatedContact);
                    }
                  },
                  onLongPress: () {
                    _deleteContact(contact.id!);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(contact: contact),
                            ),
                          );
                          // _sendSMSWithNative(contact.phone, 'Hello, this is a test message.');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () async {
                          _callContact(contact.phone); // Appel du contact
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
