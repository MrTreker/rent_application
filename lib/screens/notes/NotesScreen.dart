import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:rent_application/theme/model_theme.dart';
import 'package:rent_application/widgets/firstAlertDialog.dart';
import 'package:provider/provider.dart';

/// Widget for the root/initial pages in the bottom navigation bar.
class NotesScreen extends StatefulWidget {
  /// Creates a RootScreen
  const NotesScreen(
      {required this.label,
      required this.detailsPath,
      required this.detailsHomePhonePath,
      required this.detailsApartmentsPath,
      Key? key})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsApartmentsPath;

  /// The path to the detail page
  final String detailsPath;

  /// The path to the detail page
  final String detailsHomePhonePath;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    //WidgetsBinding.instance.addPostFrameCallback(alertFirst);
    super.initState();
  }

  // void alertFirst(_) {
  //   // Первое привествие
  //   Future.delayed(Duration(seconds: 0), () {
  //     showDialog(context: context, builder: (context) => FirstAlertDialog());
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Заметки'),
          actions: [
            IconButton(
                icon: Icon(themeNotifier.isDark
                    ? Icons.nightlight_round
                    : Icons.wb_sunny),
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
                })
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () => Beamer.of(context)
                        .beamToNamed(widget.detailsHomePhonePath),
                    child: const Text('Домофоны',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () => Beamer.of(context)
                        .beamToNamed(widget.detailsApartmentsPath),
                    child: const Text('Квартиры',
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
