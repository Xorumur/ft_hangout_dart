import 'dart:io'; // Pour gérer les fichiers
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Ajouter le package image_picker
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'contact.dart';
import 'Language.dart'; // Importer la classe Language
import 'ColorSelectionPage.dart';
import 'package:intl/intl.dart'; // Importer le package intl

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> with WidgetsBindingObserver {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  Color _appBarColor = Colors.blue; // Couleur par défaut de l'AppBar
  String? _lastPausedTime; // Variable pour stocker l'heure à laquelle l'application a été mise en pause
  File? _selectedImage; // Fichier pour stocker l'image sélectionnée
  final ImagePicker _picker = ImagePicker(); // ImagePicker pour sélectionner une image

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Ajouter l'observateur
    _loadLastPausedTime(); // Charger l'heure à laquelle l'application a été mise en pause
    _loadAppBarColor();  // Charger la couleur de l'AppBar lors de l'initialisation
  }

  // Méthode pour sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image : $e");
    }
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
    WidgetsBinding.instance.removeObserver(this); // Retirer l'observateur
    super.dispose();
  }

  void _saveContact() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Language.resolve('Please select an image.'))),
      );
      return;
    }
    // Check that all fields are filled
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Language.resolve('Please fill all fields.'))),
      );
      return;
    }

    final newContact = Contact(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      age: int.parse(_ageController.text),
      image: _selectedImage!.path, // Sauvegarder le chemin de l'image
    );
    Navigator.of(context).pop(newContact); // Retourner à la page précédente après sauvegarde
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
        backgroundColor: _appBarColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Language.resolve("add_contact")),
            if (_lastPausedTime != null)
              Text(
                'Paused at: $_lastPausedTime',
                style: TextStyle(fontSize: 14.0),
              ),
          ],
        ),
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
            GestureDetector(
              onTap: _pickImage, // Appel de la galerie
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null
                    ? Icon(Icons.add_a_photo, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: Language.resolve('firstName')),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: Language.resolve('lastName')),
            ),
            TextField(              
              maxLength: 10,
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,  // Permet uniquement les chiffres
              ],
              decoration: InputDecoration(labelText: Language.resolve('phone')),
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: InputDecoration(labelText: Language.resolve('Email')),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
               inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,  // Permet uniquement les chiffres
              ],
              decoration: InputDecoration(labelText: Language.resolve('Age')),
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
