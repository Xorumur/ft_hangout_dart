import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_service.dart';
import 'contact.dart';
import 'package:collection/collection.dart';
 
class SmsListener with ChangeNotifier {
  static const platform = MethodChannel('sms_sender');

  SmsListener() {
    _initializeSmsListener();
  }

  void _initializeSmsListener() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == "onSmsReceived") {
        final String sender = call.arguments['sender'];
        final String message = call.arguments['message'];
        print("SMSLISTENER: Received SMS from $sender: $message");
        final Contact? contact = await _findContactByPhoneNumber(sender);
        if (contact != null) {
          await DatabaseService.instance.insertMessage(contact.id!, message, false);
          notifyListeners();  // Notifie les observateurs que quelque chose a changé
        } else {
          try {
              print("Contact not found for phone number $sender and message $message");
              final newContact = Contact(
                firstName: sender,
                lastName: "Unknown",
                phone: sender,
                email: "Unknown",
                age: 0,
                image: "falsepath",
              );
              var db = await DatabaseService.instance.createContact(newContact);
              print("db: ${db.id} ${db.phone}");
              await DatabaseService.instance.insertMessage(db.id!, message, false);

              // var ContactDb = await DatabaseService.instance.getMessages(newContact.id!);
              // print("ContactDb: $ContactDb");
            } catch (e) {
              print('An error occurred: $e');  // Imprime toute erreur qui survient
          }
          // print("Contact not found for phone number $sender");
          // final newContact = Contact(
          //   firstName: "Unknown",
          //   lastName: "Unknown",
          //   phone: sender,
          //   email: "Unknown",
          //   age: 0,
          //   image: null,
          // );
          // await DatabaseService.instance.createContact(newContact);
          // await DatabaseService.instance.insertMessage(newContact.id!, message, false);
          // List<Contact> contactCount = await DatabaseService.instance.readAllContacts();
          // print('test');
          notifyListeners();
        }
      }
    });
  }

  Future<Contact?> _findContactByPhoneNumber(String phoneNumber) async {
    final List<Contact> contacts = await DatabaseService.instance.readAllContacts();
    return contacts.firstWhereOrNull((contact) => contact.phone == phoneNumber);
  }
}
