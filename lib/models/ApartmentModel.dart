import 'package:cloud_firestore/cloud_firestore.dart';

class ApartmentModel {
  String address;
  String number;
  String mainPhoto;
  String validPhoto;

  ApartmentModel(
      {required this.address,
      required this.number,
      required this.mainPhoto,
      required this.validPhoto});

  factory ApartmentModel.fromJson(Map json) => ApartmentModel(
      address: json['address'] ?? null,
      number: json['number'] ?? null,
      mainPhoto: json['mainPhoto'] ?? null,
      validPhoto: json['validPhoto']);
}
