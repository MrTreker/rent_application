import 'package:flutter/material.dart';
import 'package:rent_application/helpers/size_config.dart';

class FirstAlertDialog extends StatefulWidget {
  const FirstAlertDialog({Key? key}) : super(key: key);

  @override
  State<FirstAlertDialog> createState() => _FirstAlertDialogState();
}

class _FirstAlertDialogState extends State<FirstAlertDialog> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 10), () {
      Navigator.pop(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      insetPadding: EdgeInsets.only(
          left: 3.0.toAdaptive(context), right: 5.0.toAdaptive(context)),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: 11.0.toAdaptive(context),
                right: 11.0.toAdaptive(context)),
            height: 350,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80.0.toAdaptive(context),
                ),
                Center(
                  child: Text(
                    'Добро пожаловать в приложение. Данное окно закроется через 10 секунд',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 35.0.toAdaptive(context),
                ),
                Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 199, 16, 3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
