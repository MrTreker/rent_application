import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:rent_application/theme/model_theme.dart';
import 'package:rent_application/widgets/firstAlertDialog.dart';
import 'package:provider/provider.dart';

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatefulWidget {
  /// Creates a RootScreen
  const RootScreen({required this.label, required this.detailsPath, Key? key})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
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
          title: Text('Root Screen - ${widget.label}'),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Screen ${widget.label}',
                  style: Theme.of(context).textTheme.titleLarge),
              const Padding(padding: EdgeInsets.all(4)),
              TextButton(
                onPressed: () =>
                    Beamer.of(context).beamToNamed(widget.detailsPath),
                child: const Text('View details'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
