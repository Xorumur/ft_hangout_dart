// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:ft_hangout/SmsListener.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'ColorSelectionPage.dart';
// import 'Language.dart';
// import 'database_service.dart';
// import 'contact.dart';
// import 'SmsListener.dart'; // Importer SmsListener

// class ChatPage extends StatefulWidget {
//   final Contact contact;

//   const ChatPage({Key? key, required this.contact}) : super(key: key);

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver{
//   final TextEditingController _messageController = TextEditingController();
//   List<Map<String, dynamic>> _messages = [];
//   static const platform = MethodChannel('sms_sender'); // Ajout du MethodChannel pour l'envoi de SMS natif
//   String? _lastPausedTime; // Variable pour stocker l'heure à laquelle l'application a été mise en pause
//   Color _appBarColor = Colors.blue; // Couleur par défaut de l'AppBar

//   @override
//   void initState() {
//     super.initState();
//     _loadMessages();
//     _loadLastPausedTime(); // Charger l'heure à laquelle l'application a été mise en pause
//     print('ChatPage: ${widget.contact.firstName} ${widget.contact.lastName} ${widget.contact.id}');
//   }

//   Future<void> _sendSMSWithNative(String phoneNumber, String message) async {
//     try {
//       final result = await platform.invokeMethod('sendSMS', {
//         'phoneNumber': phoneNumber,
//         'message': message,
//       });
//       print(result);
//     } catch (e) {
//       print("Failed to send SMS: $e");
//     }
//   }

//   Future<void> _loadMessages() async {
//     final messages = await DatabaseService.instance.getMessages(widget.contact.id!);
//     setState(() {
//       _messages = messages;
//     });
//   }

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

//   Future<void> _sendMessage() async {
//     final message = _messageController.text.trim();
//     if (message.isNotEmpty) {
//       await _sendSMSWithNative(widget.contact.phone, message);
//       // Insérer le message dans la base de données comme envoyé
//       await DatabaseService.instance.insertMessage(widget.contact.id!, message, true);

//       // Simuler la réponse d'un message reçu
//       Future.delayed(Duration(seconds: 2), () async {
//         await DatabaseService.instance.insertMessage(widget.contact.id!, 'Re: $message', false);
//         _loadMessages();
//       });

//       _messageController.clear();
//       _loadMessages();
//     }
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//         WidgetsBinding.instance.removeObserver(this); // Retirer l'observateur

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

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SmsListener>(
//       builder : (context, smsListener, child) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.contact.firstName} ${widget.contact.lastName}'),
//         backgroundColor: _appBarColor,
//         actions: [
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
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isSent = message['isSent'] == 1;
//                 final alignment = isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
//                 final color = isSent ? Colors.blue : Colors.grey;

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                   child: Column(
//                     crossAxisAlignment: alignment,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12.0),
//                         decoration: BoxDecoration(
//                           color: color,
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Text(
//                           message['message'],
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       Text(
//                         DateFormat('HH:mm, d MMM y').format(DateTime.parse(message['timestamp'])),
//                         style: TextStyle(fontSize: 12.0),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: Language.resolve('typeMessage'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ft_hangout/SmsListener.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'ColorSelectionPage.dart';
import 'Language.dart';
import 'database_service.dart';
import 'contact.dart';

class ChatPage extends StatefulWidget {
  final Contact contact;

  const ChatPage({Key? key, required this.contact}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  static const platform = MethodChannel('sms_sender');
  String? _lastPausedTime;
  Color _appBarColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadLastPausedTime();
  }

  Future<void> _sendSMSWithNative(String phoneNumber, String message) async {
    try {
      final result = await platform.invokeMethod('sendSMS', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      print(result);
    } catch (e) {
      print("Failed to send SMS: $e");
    }
  }

  Future<void> _loadMessages() async {
    final messages = await DatabaseService.instance.getMessages(widget.contact.id!);
    setState(() {
      _messages = messages;
    });
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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await _sendSMSWithNative(widget.contact.phone, message);
      await DatabaseService.instance.insertMessage(widget.contact.id!, message, true);
      _messageController.clear();
      _loadMessages();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SmsListener>(
      builder: (context, smsListener, child) {
        _loadMessages(); // Recharger les messages quand un SMS est reçu
        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.contact.firstName} ${widget.contact.lastName}'),
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
                icon: const Icon(Icons.language),
                onPressed: () async {
                  await Language.changeLanguage();
                  setState(() {});
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isSent = message['isSent'] == 1;
                    final alignment = isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                    final color = isSent ? Colors.blue : Colors.grey;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: alignment,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              message['message'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm, d MMM y').format(DateTime.parse(message['timestamp'])),
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: Language.resolve('typeMessage'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
