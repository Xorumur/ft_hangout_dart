import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact.dart';
import 'ColorSelectionPage.dart';
import 'Language.dart';
import 'package:intl/intl.dart'; // Importer le package intl

class EditContactPage extends StatefulWidget {
  final Contact contact;

  const EditContactPage({super.key, required this.contact});

  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> with WidgetsBindingObserver {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  Color _appBarColor = Colors.blue; // Couleur par défaut de l'AppBar
  String? _lastPausedTime; // Variable pour stocker l'heure à laquelle l'application a été mise en pause

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Ajouter l'observateur
    _loadLastPausedTime(); // Charger l'heure à laquelle l'application a été mise en pause
    _loadAppBarColor();  // Charger la couleur de l'AppBar lors de l'initialisation
    _firstNameController = TextEditingController(text: widget.contact.firstName);
    _lastNameController = TextEditingController(text: widget.contact.lastName);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _emailController = TextEditingController(text: widget.contact.email);
    _ageController = TextEditingController(text: widget.contact.age.toString());
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
    if (mounted) {
      setState(() {
        _lastPausedTime = now;
      });
    }
  }

  Future<void> _loadLastPausedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPausedTimeString = prefs.getString('lastPausedTime');
    if (lastPausedTimeString != null) {
      final lastPausedTime = DateTime.parse(lastPausedTimeString);
      if (mounted) {
        setState(() {
          _lastPausedTime = DateFormat('HH:mm, d MMM y').format(lastPausedTime);
        });
      }
    }
  }

  Future<void> _loadAppBarColor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appBarColor = Color(prefs.getInt('appBarColor') ?? Colors.blue.value);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _saveContact() {
    final updatedContact = Contact(
      id: widget.contact.id,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      age: int.parse(_ageController.text),
    );

    Navigator.of(context).pop(updatedContact);
  }

  Future<void> _setAppBarColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appBarColor = color;
    });
    await prefs.setInt('appBarColor', color.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Language.resolve("edit_contact")),
            if (_lastPausedTime != null)
              Text(
                'Paused at: $_lastPausedTime',
                style: TextStyle(fontSize: 14.0),
              ),
          ],
        ),
        backgroundColor: _appBarColor,
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: Language.resolve('firstName')),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: Language.resolve('lastName')),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: Language.resolve('phone')),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: Language.resolve('Email')),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: Language.resolve('Age')),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveContact,
              child: Text(Language.resolve('Save')),
            ),
          ],
        ),
      ),
    );
  }
}
