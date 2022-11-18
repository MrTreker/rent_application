import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_application/repository/firebase_auth.dart';
import 'package:rent_application/theme/model_theme.dart';
import 'package:rent_application/widgets/custom_snackBar.dart';
import 'package:provider/provider.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({super.key});

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firebaseDB = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name = '';

  void _validateSaveUserInfo() async {
    final FormState? form = _formKey.currentState;
    if (_formKey.currentState!.validate()) {
      form!.save();
      FireBaseAuth.addUser(
          name: _name, uid: _auth.currentUser!.uid, context: context);
    } else if (!_formKey.currentState!.validate()) {
      CustomSnackBar(context, Text('Заполните поле'), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
      return Scaffold(
        key: _scaffoldKey,
        //backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Регистрация'),
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
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Регистрация',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 20, left: 10, right: 20, bottom: 13),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Укажите имя',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor),
                            ),
                            TextFormField(
                              onSaved: (input) {
                                setState(() {
                                  _name = input!;
                                });
                              },
                              decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFFF0000)),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 0),
                                prefixIcon: Container(
                                    child: Icon(
                                  Icons.account_box,
                                  color: Theme.of(context).primaryColor,
                                )),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFC5CEE0)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFC5CEE0)),
                                ),
                                hintText: 'Введите имя',
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _validateSaveUserInfo();
                              },
                              child: Center(child: Text('Зарегистрироваться')),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
