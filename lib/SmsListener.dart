import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_service.dart';
import 'contact.dart';

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
        print("Received SMS from $sender: $message");
        final Contact? contact = await _findContactByPhoneNumber(sender);
        if (contact != null) {
          await DatabaseService.instance.insertMessage(contact.id!, message, false);
          notifyListeners();  // Notifie les observateurs que quelque chose a changé
        }
      }
    });
  }

  Future<Contact?> _findContactByPhoneNumber(String phoneNumber) async {
    final List<Contact> contacts = await DatabaseService.instance.readAllContacts();
    return contacts.firstWhere((contact) => contact.phone == phoneNumber);
  }
}
