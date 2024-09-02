import 'package:flutter/material.dart';
import 'contact.dart';
import 'database_service.dart';  // Importer la classe DatabaseService
import 'EditContactPage.dart';  // Importer la page d'édition
import 'AddContactPage.dart';  // Importer la page d'ajout


class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> contacts = [];

  // Méthode pour charger les contacts depuis la base de données
  Future<void> _loadContacts() async {
    final loadedContacts = await DatabaseService.instance.readAllContacts();
    setState(() {
      contacts = loadedContacts;
    });
  }

  // Méthode pour ajouter un contact à la base de données
  Future<void> _addContact(Contact contact) async {
    await DatabaseService.instance.createContact(contact);
    _loadContacts();  // Recharger les contacts après ajout
  }

  // Méthode pour mettre à jour un contact dans la base de données
  Future<void> _updateContact(Contact updatedContact) async {
    await DatabaseService.instance.updateContact(updatedContact);
    _loadContacts();  // Recharger les contacts après modification
  }

  // Méthode pour supprimer un contact de la base de données
  Future<void> _deleteContact(int id) async {
    await DatabaseService.instance.deleteContact(id);
    _loadContacts();  // Recharger les contacts après suppression
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();  // Charger les contacts lors de l'initialisation de la page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Simuler l'ajout d'un contact pour tester
              final newContact = await Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const AddContactPage()
                  )
                );

                if (newContact != null) {
                  _addContact(newContact);
                }

              // final newContact = Contact(firstName: 'New', lastName: 'Contact', phone: '123456789', email: 'new@example.com', age: 30);
              // _addContact(newContact);
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
                  Text('Phone: ${contact.phone}'),
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
            ),
          );
        },
      ),
    );
  }
}
