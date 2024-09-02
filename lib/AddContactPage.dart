import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_service.dart';
import 'contact.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

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
    // Pour le moment, on simule l'ajout du contact. On pourrait l'ajouter dans la base SQLite.
    print('Contact Saved: ${_firstNameController.text}, ${_lastNameController.text}, ${_phoneController.text}');
    final newContacts = Contact(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      age: int.parse(_ageController.text),
    );
    Navigator.of(context).pop(newContacts); // Retourner à la page précédente après sauvegarde
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(              
              maxLength: 10,
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,  // Permet uniquement les chiffres
              ],
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
               inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,  // Permet uniquement les chiffres
              ],
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveContact,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
