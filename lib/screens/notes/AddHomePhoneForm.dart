import 'package:flutter/material.dart';
import 'package:rent_application/helpers/size_config.dart';
import 'package:rent_application/repository/firestore_service.dart';

class AddHomePhoneForm extends StatefulWidget {
  const AddHomePhoneForm({Key? key}) : super(key: key);

  @override
  State<AddHomePhoneForm> createState() => _AddHomePhoneFormState();
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<FormState> formKey = GlobalKey<FormState>();
Key _k1 = new GlobalKey();
Key _k2 = new GlobalKey();

class _AddHomePhoneFormState extends State<AddHomePhoneForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final GlobalKey<FormState> _formKeyRegister = GlobalKey<FormState>();
    String _address = '';
    String _code = '';

    void _validateHomePhoneData() async {
      final FormState? form = _formKey.currentState;
      if (_formKey.currentState!.validate()) {
        form!.save();
        FirestoreService.addHomePhone(_address, _code);
      } else if (!_formKey.currentState!.validate()) {
        //CustomSnackBar(context, Text('Заполните поле'), Colors.red);
      }
    }

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
            height: 370,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80.0.toAdaptive(context),
                ),
                Center(
                  child: Text(
                    'Добавление домофона',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 35.0.toAdaptive(context),
                ),
                Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          key: _k1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Поле не должно быть пустым';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (input) {
                            setState(() {
                              _address = input!;
                            });
                          },
                        ),
                        TextFormField(
                          key: _k2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Поле не должно быть пустым';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (input) {
                            setState(() {
                              _code = input!;
                            });
                          },
                        ),
                      ],
                    )),
                SizedBox(
                  height: 35.0.toAdaptive(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      color: Colors.red,
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: TextButton(
                        onPressed: () {
                          _validateHomePhoneData();
                        },
                        child: const Text('Добавить',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Отмена',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
