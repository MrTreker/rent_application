import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rent_application/helpers/helpers.dart';
import 'package:rent_application/helpers/message_exception.dart';
import 'package:rent_application/helpers/size_config.dart';
import 'package:rent_application/repository/firebase_auth.dart';
import 'package:rent_application/theme/model_theme.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:rent_application/widgets/custom_snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyRegister = GlobalKey<FormState>();
  int numScreen = 1;

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool codeSumbit = false;
  String _verificationID = '';
  bool codeVerify = true;
  final _pinPutController = TextEditingController();
  TextEditingController _phone = TextEditingController();

  getPage() {
    switch (numScreen) {
      case 1:
        return phoneForm();
        break;
      case 2:
        return emailForm();
        break;
      default:
    }
  }

  setPage(value) {
    setState(() {
      numScreen = value;
    });
  }

  void _validateAuth() async {
    final FormState? form = _formKey.currentState;
    if (_formKey.currentState!.validate()) {
      helpers.showProgress(
          context, 'Выполняется вход, пожалуйста подождите', false);
      form!.save();
      try {
        bool result = await fbAuth.auth(_email, _password);
        if (result) {
          helpers.hideProgress();
          print('Document exists on the database');
          Navigator.pushNamedAndRemoveUntil(
              context, 'tabNavigator', (Route<dynamic> route) => false);
        } else {
          helpers.hideProgress();
          Navigator.pushNamed(context, 'registrationScreen');
        }
      } on MessageException catch (e) {
        helpers.hideProgress();
        print(e);
        CustomSnackBar(context, Text(e.message), Colors.lightGreen);
      }
    }
  }

  _phoneAuth() async {
    try {
      await fbAuth.submitPhoneNumber(
          phoneNumber: _phone.text,
          func: (value) {
            setState(() {
              _verificationID = value;
            });
            if (_verificationID != null) {
              CustomSnackBar(
                  context, Text('СМС код был выслан'), Colors.lightGreen);
              setState(() {
                codeSumbit = false;
                numScreen = 4;
              });
            }
          },
          durationCode: () {
            setState(() {
              codeSumbit = true;
            });
          });
    } on MessageException catch (e) {
      CustomSnackBar(context, Text(e.message), Colors.red);
    }
  }

  Widget _authButton(context,
      {required IconData iconName, required Function func}) {
    return Container(
      height: 25,
      width: 25,
      child: TextButton(
          onPressed: () {
            func();
          },
          child: Icon(iconName)),
    );
  }

  Widget emailForm() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Вход по Email',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Theme.of(context).cardColor,
          ),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Электронная почта',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                onSaved: (input) {
                  _email = input!;
                },
                validator: (value) {
                  if (value != null || value!.isNotEmpty) {
                    final RegExp regex = RegExp(
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)| (\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                    if (!regex.hasMatch(value))
                      return 'Введите корректный email';
                    else
                      return null;
                  } else {
                    return 'Введите корректный email';
                  }
                },
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF0000)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                  prefixIcon: Container(child: Icon(Icons.email)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC5CEE0)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC5CEE0)),
                  ),
                  hintText: 'Example@mail.com',
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                'Пароль',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                obscureText: _obscurePassword,
                onSaved: (input) => _password = input!,
                validator: (input) {
                  if (input!.isEmpty) {
                    return "Неверный пароль";
                  } else {
                    if (input.length < 6) {
                      return "Пароль слишком короткий";
                    } else {
                      return null;
                    }
                  }
                },
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF0000)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(Icons.remove_red_eye),
                  ),
                  prefixIcon: Container(child: Icon(Icons.password)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC5CEE0)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC5CEE0)),
                  ),
                  hintText: 'Введите пароль',
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(
                height: 25.0,
              ),

              SizedBox(
                height: 25.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () {
                    _validateAuth();
                  },
                  child: const Text('Войти'),
                ),
              ),

              SizedBox(
                height: 14,
              ),
              // Center(
              //     child:
              //     FlatButton(
              //   onPressed: () {
              //     // Navigator.push(
              //     //     context,
              //     //     MaterialPageRoute(
              //     //         builder: (context) => PasswordRecoveryScreen()));
              //   },
              //   child: Text(
              //     'Забыли пароль?',
              //     style: TextStyle(fontSize: 14).copyWith(fontSize: 16),
              //   ),
              // )),
              SizedBox(
                height: 25,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: Color(0xFFE7EBF2),
              ),
              SizedBox(
                height: 20,
              ),
              socialLink()
            ]),
          ),
        ),
      ],
    );
  }

  Widget phoneForm() {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '+7 (###) ###-##-##', filter: {"#": RegExp(r'[0-9]')});
    return Column(
      children: [
        Text('Добро пожаловать', style: TextStyle(fontSize: 14)),
        SizedBox(
          height: 9,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Номер телефона',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [maskFormatter],
                controller: _phone,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFC5CEE0))),
                    hintText: '+7 XXX XXX XX XX',
                    hintStyle: TextStyle(fontSize: 14)),
              ),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () {
                    _phoneAuth();
                  },
                  child: const Text('Войти'),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: Color(0xFFE7EBF2),
              ),
              SizedBox(
                height: 20,
              ),
              socialLink()
            ],
          ),
        ),
      ],
    );
  }

  Widget socialLink() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Войти с помощью',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(),
            if (Platform.isAndroid)
              numScreen == 1
                  ? _authButton(context,
                      iconName: Icons.email, func: () => setPage(2))
                  : _authButton(context,
                      iconName: Icons.phone, func: () => setPage(1)),
            Container()
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size.height - 110;
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Авторизация'),
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
        body: numScreen != 4
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text('Вход в систему',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    getPage(),
                  ]))
            : Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Вход в систему',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        margin: EdgeInsets.only(
                            left: mediaQuery / 27.62,
                            right: mediaQuery / 27.62),
                        child: Column(
                          children: [
                            // Container(
                            //   height: 50.0.toAdaptive(context),
                            //   child: Center(
                            //       child:
                            //           Image.asset("assets/img/logo_text.png")),
                            // ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Введите полученный код',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 35,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width /
                                                10,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                10),
                                    child: PinPut(
                                        onSubmit: (value) async {
                                          try {
                                            bool value =
                                                await fbAuth.submitCode(
                                                    code:
                                                        _pinPutController.text,
                                                    verificationId:
                                                        _verificationID,
                                                    context: context);
                                            if (!value) {
                                              setState(() {
                                                codeVerify = false;
                                              });
                                            }
                                          } on MessageException catch (e) {
                                            CustomSnackBar(context,
                                                Text(e.message), Colors.red);
                                          }
                                        },
                                        controller: _pinPutController,
                                        fieldsCount: 6,
                                        fieldsAlignment:
                                            MainAxisAlignment.spaceAround,
                                        animationDuration: Duration(seconds: 0),
                                        textStyle: TextStyle(
                                            fontSize: 28,
                                            color: Color(0xFF323232)),
                                        preFilledWidget: Container(
                                          width: 12,
                                          height: 2,
                                          color:
                                              Color.fromRGBO(197, 206, 224, 1),
                                        )),
                                  ),
                                  if (!codeVerify)
                                    Text('Неверный код',
                                        style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
      );
    });
  }
}
