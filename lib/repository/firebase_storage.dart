import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:rent_application/helpers/firebase_constants.dart';
import 'package:rent_application/repository/firestore_service.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class StorageRepo {
  // FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://meetingchat-2d401.appspot.com');
  // final firebaseDB = FirebaseFirestore.instance;
  // var _auth = FirebaseAuth.instance;

  dowloadImageUserProfile() async {
    fbStorage.ref().child('users/123/avatar.*');
  }

  // Установка главной фотографии из слайдера фотографий
  Future<void> setMainPhoto(String url, String uid) async {
    fbFirestore.collection('apartments').doc(uid).update({'mainPhoto': url});
  }

  // Загрузка основного фото пользователем (по кнопке фотоаппарата в карточке квартиры), фото хранится независимо от других фоток
  // Главная фотография изначально загружается на модерацию
  Future<void> uploadMainPhoto(File image, String uid) async {
    print('Идентификатор квартиры2: ${uid}');
    DateTime time = DateTime.now();
    await fbStorage.ref('mainPhoto/$uid/mainPhoto').putFile(image);
    // Ссылка на аву которая еще на модерации
    String downloadUrl =
        await fbStorage.ref('mainPhoto/$uid/mainPhoto').getDownloadURL();

    await fbFirestore
        .collection('apartments')
        .doc(uid)
        .update({'mainPhoto': downloadUrl});
    //FirestoreService.addMainPhotoValid(time, 'mainPhoto/$uid/mainPhoto', uid);
  }
}

StorageRepo storageRepo = StorageRepo();
