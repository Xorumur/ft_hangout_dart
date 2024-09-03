// import 'package:flutter/material.dart';
// import 'Language.dart';

// class ColorSelectionPage extends StatelessWidget {
//   final ValueChanged<Color> onColorSelected;

//   ColorSelectionPage({required this.onColorSelected});

//   final List<Color> colors = [
//     Colors.red,
//     Colors.green,
//     Colors.blue,
//     Colors.orange,
//     Colors.purple,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select a color'),
//         actions: [
//           IconButton(
//             icon : const Icon(Icons.language),
//             onPressed: () async {
//             await Language.changeLanguage(); // Change la langue
//             setState(() {}); // Force la reconstruction de la page pour mettre à jour l'affichage
//           },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: colors.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundColor: colors[index],
//             ),
//             title: Text(colors[index].toString()),
//             onTap: () {
//               onColorSelected(colors[index]);
//               Navigator.pop(context);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

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
            title: Text(colors[index].toString()),
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
