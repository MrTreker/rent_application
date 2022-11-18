import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rent_application/helpers/firebase_constants.dart';
import 'package:rent_application/helpers/message_exception.dart';
import 'package:rent_application/screens/RegisterAccountScreen.dart';
import 'package:rent_application/screens/TabNavigator.dart';

class FireBaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String verification;
  late bool result;

  Future<void> linkEmailAndPhone(
      {required String email,
      required String password,
      required String phone,
      required String code,
      required String verificationId}) async {
    email = 'test@test.ru';
    password = '123456';
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    final UserCredential emailCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    try {
      AuthCredential phoneAuth = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);
      await emailCredential.user!.linkWithCredential(phoneAuth).then((value) {
        print(value);
      });
    } catch (exception) {
      throw MessageException('Введен не верный код');
    }
  }

  Future resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (_) {
      throw MessageException('Данная почта не зарегистрированна');
    }
  }

  Future<bool> auth(String email, String password) async {
    try {
      var auth = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (auth.user != null) {
        result = await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.user!.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          return documentSnapshot.exists;
        });
      }
      return result;
      // throw MessageException('Пользователь не существует');
    } on FirebaseAuthException catch (_) {
      throw MessageException('Логин или пароль не верны');
    }
  }

  Future submitPhoneNumber(
      {required String phoneNumber,
      Function? func,
      required Function durationCode}) async {
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (AuthCredential phoneAuthCredential) {},
          verificationFailed: (FirebaseAuthException error) {
            print('${error.message}');
            throw MessageException('Данный номер телефона не зарегистрирован');
          },
          codeSent: (String verificationId, [int? forceResendingToken]) {
            func!(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            durationCode();
            print('Время истекло можно запросить повторный код');
          });
    } catch (e) {
      throw MessageException('Введите корректный номер телефона');
    }
  }

  Future<bool> submitCode(
      {required String code,
      required String verificationId,
      BuildContext? context}) async {
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);
      await _auth.signInWithCredential(phoneAuthCredential).then((result) {
        if (_auth.currentUser != null) {
          print('Отправка кода выполнилась делаем редирект');
          _redirectAuthUser(context!);
        } else {
          print('Ничего не делаем');
        }
      });
      return true;
    } catch (exception) {
      return false;
      // throw MessageException('Введен не верный код');
    }
  }

  Future phoneAuth(
      {required String phone,
      required String smsCode,
      required Function func}) async {
    print('Номер телефона: $phone');
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Авторизация пользователя (или ссылка) с автоматически созданными учетными данными
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Обработчик ошибок
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
          throw MessageException('Данный номер телефона не действителен');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Ждем когда введут код из смс
        //Не совсем понял, видимо создаем учетные данные уже с смс кодом
        PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: "123456");
        //Выполняем вход
        await _auth.signInWithCredential(phoneAuthCredential);

        if (_auth.currentUser != null) {
          func();
        } else {
          print('error sms code');
          throw MessageException('Данный номер телефона не действителен');
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // По дэфолту ждет 30 секунд пока введут код
        // Тут можно обработать событие, когда истечет время
      },
    );
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future signinWithCredential(AuthCredential credential,
      {bool verified = true}) async {
    //Sign in to Firebase
    final result = _auth.signInWithCredential(credential);
    print(result);
  }

  _redirectAuthUser(BuildContext context) async {
    DocumentSnapshot documentSnapshot =
        await fbFirestore.collection('users').doc(_auth.currentUser!.uid).get();
    var user;
    if (documentSnapshot != null && documentSnapshot.exists) {
      if (user.name != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => TabNavigator()),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => RegisterAccountScreen()),
        );
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => RegisterAccountScreen()),
      );
    }
  }

  static Future<Object?> addUser(
      {required String name,
      required String uid,
      required BuildContext context}) async {
    return fbFirestore
        .collection('users')
        .doc(uid)
        .set({
          'name': name, // John Doe

          'uid': uid, // 42
        })
        .then((value) => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TabNavigator()),
            ))
        .catchError((error) => print("Failed to add user: $error"));
  }
}

class LoginResult {}

FireBaseAuth fbAuth = FireBaseAuth();
