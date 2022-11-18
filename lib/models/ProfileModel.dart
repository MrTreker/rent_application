import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  String uid;
  String name; // Имя

  ProfileModel({
    required this.uid,
    required this.name,
  });

  factory ProfileModel.fromJson(Map json) => ProfileModel(
        uid: json['uid'] ?? null,
        name: json['name'] ?? null,
      );
}
