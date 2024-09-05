import 'dart:io'; // Pour gérer les fichiers
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Ajouter le package image_picker
import 'package:shared_preferences/shared_preferences.dart';
import 'contact.dart';
import 'ColorSelectionPage.dart';
import 'Language.dart';
import 'package:intl/intl.dart';

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
  Color _appBarColor = Colors.blue;
  String? _lastPausedTime;
  File? _selectedImage; // Pour stocker l'image sélectionnée
  final ImagePicker _picker = ImagePicker(); // ImagePicker pour sélectionner une image

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastPausedTime();
    _loadAppBarColor();

    _firstNameController = TextEditingController(text: widget.contact.firstName);
    _lastNameController = TextEditingController(text: widget.contact.lastName);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _emailController = TextEditingController(text: widget.contact.email);
    _ageController = TextEditingController(text: widget.contact.age.toString());

    // Charger l'image existante du contact
    if (widget.contact.image != null) {
      _selectedImage = File(widget.contact.image!);
    }
  }

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
      _saveLastPausedTime();
    } else if (state == AppLifecycleState.resumed) {
      _loadLastPausedTime();
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
    // Check that all fields are valid before saving
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


    final updatedContact = Contact(
      id: widget.contact.id,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      age: int.parse(_ageController.text),
      image: _selectedImage?.path, // Sauvegarder le chemin de l'image sélectionnée
    );

    Navigator.of(context).pop(updatedContact); // Retourner le contact modifié
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
            await Language.changeLanguage();
            setState(() {});
          },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage, // Appel à la galerie
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
