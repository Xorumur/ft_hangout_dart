import 'package:flutter/material.dart';
import 'Language.dart';

class ColorSelectionPage extends StatefulWidget {
  final ValueChanged<Color> onColorSelected;

  ColorSelectionPage({required this.onColorSelected});

  @override
  _ColorSelectionPageState createState() => _ColorSelectionPageState();
}

class _ColorSelectionPageState extends State<ColorSelectionPage> {
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  String getColorName(Color color) {
    if (color == Colors.red) {
      return Language.resolve('Red');
    } else if (color == Colors.green) {
      return Language.resolve('Green');
    } else if (color == Colors.blue) {
      return Language.resolve('Blue');
    } else if (color == Colors.orange) {
      return Language.resolve('Orange');
    } else if (color == Colors.purple) {
      return Language.resolve('Purple');
    } else {
      return Language.resolve('Unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Language.resolve('SelectColor')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () async {
              await Language.changeLanguage(); // Change la langue
              setState(() {}); // Force la reconstruction de la page pour mettre à jour l'affichage
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colors[index],
            ),
            title: Text(getColorName(colors[index])),
            onTap: () {
              widget.onColorSelected(colors[index]);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
