import 'package:flutter/material.dart';
import 'contact.dart';
import 'database_service.dart';

class ContactNotifier extends ChangeNotifier {
  List<Contact> contacts = [];

  ContactNotifier() {
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    contacts = await DatabaseService.instance.readAllContacts();
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    await DatabaseService.instance.createContact(contact);
    _loadContacts();  // Recharger la liste des contacts après ajout
  }

  Future<void> updateContact(Contact updatedContact) async {
    await DatabaseService.instance.updateContact(updatedContact);
    _loadContacts();  // Recharger la liste des contacts après mise à jour
  }

  Future<void> deleteContact(int id) async {
    await DatabaseService.instance.deleteContact(id);
    _loadContacts();  // Recharger la liste des contacts après suppression
  }
}
