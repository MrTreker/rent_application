import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rent_application/helpers/size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_application/models/ApartmentModel.dart';
import 'package:rent_application/repository/firebase_auth.dart';
import 'package:rent_application/repository/firebase_storage.dart';
import 'package:rent_application/repository/firestore_service.dart';
import 'package:rent_application/widgets/custom_snackBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AddApartmentsForm extends StatefulWidget {
  final String uid;
  const AddApartmentsForm({Key? key, required this.uid}) : super(key: key);

  @override
  State<AddApartmentsForm> createState() => _AddApartmentsFormState(uid);
}

class _AddApartmentsFormState extends State<AddApartmentsForm> {
  final String uid = '';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late File _image;
  final picker = ImagePicker();
  Key _k1 = new GlobalKey();
  Key _k2 = new GlobalKey();

  bool loadingAvatar = false;
  double percent = 100;

  _AddApartmentsFormState(String uid) : super();
  int get maxLengthPhoto => 10 - photos.length;

  late String? photoUrl;
  List<String> moderatorPhotos = [];
  List<String> photos = [];

  List<Asset> images = <Asset>[];

  ApartmentModel apartment = new ApartmentModel(
      address: 'address',
      number: 'code',
      mainPhoto: 'mainPhoto',
      validPhoto: '');

  @override
  void initState() {
    super.initState();
  }

  Future _getImageAvatar(ImageSource source) async {
    setState(() {
      loadingAvatar = true;
    });
    final pickedFile = await picker.getImage(source: source, imageQuality: 60);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      print('Фото загружено');
      await storageRepo.uploadMainPhoto(_image, widget.uid);
      //await MyAppState.updateCurrentUser();
      //profile = MyAppState.currentUser;
      setState(() {
        loadingAvatar = false;
      });
    } else {
      setState(() {
        loadingAvatar = false;
      });
      print('No image selected.');
    }
  }

  _getImages() async {
    // List<String> photosUrl =
    //     await storageRepo.getUserPhotos(_auth.currentUser.uid);
    setState(() {
      photos.clear();
      _getModeratorImages();
      //photos = photosUrl;
    });
  }

  _getModeratorImages() async {
    // List<String> photosUrl =
    //     await storageRepo.getUserModeratorPhotos(_auth.currentUser.uid);
    setState(() {
      moderatorPhotos.clear();
      //moderatorPhotos = photosUrl;
    });
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source, imageQuality: 60);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Фото загружено');
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: maxLengthPhoto,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#6563FF",
          actionBarTitle: "Количество фотографий",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e.toString());
    }

    if (resultList.length > 0) {
      double count = 100 / resultList.length;
      setState(() {
        percent = 0;
      });

      await _getImages();
      setState(() {});
    }
  }

//функция преобразования списка снапшотов коллекции в список сообщений
  StreamTransformer<QuerySnapshot<Map<String, dynamic>>, ApartmentModel>
      documentToApartmentsTransformer = StreamTransformer<
              QuerySnapshot<Map<String, dynamic>>, ApartmentModel>.fromHandlers(
          handleData: (QuerySnapshot<Map<String, dynamic>> snapShot,
              EventSink<ApartmentModel> sink) {
    ApartmentModel result;
    snapShot.docs.forEach(((element) {
      FirestoreService.getApartments(element.id).then((value) {
        if (value != null) {
          sink.add(ApartmentModel(
              address: value['address'],
              number: value['number'],
              mainPhoto: value['mainPhoto'],
              validPhoto: value['validPhoto']));
          //sink.add(result = List.from(result.reversed));
        }
      });
    }));
  });

  @override
  Widget build(BuildContext context) {
    String _address = '';
    String _number = '';

    void _validateApartmentData() async {
      final FormState? form = formKey.currentState;
      if (formKey.currentState!.validate()) {
        form!.save();
        FirestoreService.addApartment(
          _address,
          _number,
          photoUrl!,
          widget.uid,
        );
        Navigator.of(context).pop();
      } else if (!formKey.currentState!.validate()) {
        //CustomSnackBar(context, Text('Заполните поле'), Colors.red);
      }
    }

    return SingleChildScrollView(
      child: Dialog(
        key: scaffoldKey,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        insetPadding: EdgeInsets.only(
            left: 3.0.toAdaptive(context), right: 5.0.toAdaptive(context)),
        child: Container(
          margin: EdgeInsets.only(left: 10, top: 15, right: 10),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Container(
                  //height: 431,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Добавление Квартиры',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          softWrap: true,
                        ),
                      ),
                      SizedBox(
                        height: 10.0.toAdaptive(context),
                      ),
                      Stack(
                        children: [
                          Container(
                            // height: 336,
                            width: MediaQuery.of(context).size.width,
                            child: !loadingAvatar
                                ? StreamBuilder<ApartmentModel>(
                                    stream: FirebaseFirestore.instance
                                        .collection('apartments')
                                        .snapshots()
                                        .transform(
                                            documentToApartmentsTransformer),
                                    builder: (context, snapshot) {
                                      print(
                                          'Фотография: ${snapshot.data?.mainPhoto}');

                                      photoUrl = snapshot.data?.mainPhoto;

                                      return snapshot.data?.mainPhoto == null ||
                                              snapshot.data?.mainPhoto == ''
                                          ? Image.network(
                                              'https://careappointments.com/wp-content/uploads/2018/10/no_image_placeholder.png',
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              snapshot.data!.mainPhoto,
                                              fit: BoxFit.cover,
                                            );
                                    })
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: InkWell(
                              onTap: () async {
                                await Permission.camera.request();
                                var status = await Permission.microphone.status;
                                if (status.isGranted) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                            title: Text(
                                                'Загрузить изображение из'),
                                            children: [
                                              SimpleDialogOption(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _getImageAvatar(
                                                      ImageSource.gallery);
                                                },
                                                child: Text('Галерея'),
                                              ),
                                              SimpleDialogOption(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _getImageAvatar(
                                                      ImageSource.camera);
                                                },
                                                child: Text('Камера'),
                                              )
                                            ],
                                          ));
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: Icon(Icons.camera_alt_outlined),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   top: 62,
                          //   right: 5,
                          //   child: InkWell(
                          //     onTap: () async {
                          //       //await _showDialogDeleteAvatar();
                          //     },
                          //     child: Container(
                          //       padding: EdgeInsets.symmetric(vertical: 15),
                          //       width: 50,
                          //       height: 50,
                          //       decoration: BoxDecoration(
                          //           color: Colors.red,
                          //           borderRadius:
                          //               BorderRadius.all(Radius.circular(5))),
                          //       child: Icon(Icons.delete_forever),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
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
                            _number = input!;
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
                        _validateApartmentData();
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
              ),
              SizedBox(
                height: 35.0.toAdaptive(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoWidget(String url, bool validPhoto) {
    return Container(
      margin: EdgeInsets.only(left: 5),
      height: 90,
      width: 75,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Padding(
              padding: const EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          if (!validPhoto)
            Positioned(
                top: 0,
                right: 0,
                child: Container(
                    height: 20,
                    width: 20,
                    child: Icon(Icons.watch_later_outlined))),
          if (validPhoto)
            Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () {
                    // showDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return _alertAvatar(
                    //           context, url, _auth.currentUser.uid);
                    //     });
                  },
                  child: Container(
                      height: 43,
                      width: 28,
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Icon(Icons.image)),
                )),
          if (validPhoto)
            Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () {
                    print('Ссылка на изображение: $url');
                    // showDialog(
                    //     context: context,
                    //     builder: (context) => _alerdDellPhoto(context, url));
                  },
                  child: Container(
                      height: 43,
                      width: 28,
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Icon(Icons.delete)),
                )),
        ],
      ),
    );
  }

  Widget _addPhoto() {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => SimpleDialog(
                  title: Text('Загрузить изображение из'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                        loadAssets();
                        // _getImage(ImageSource.gallery);
                      },
                      child: Text('Гелерея'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                        _getImage(ImageSource.camera);
                      },
                      child: Text('Камера'),
                    )
                  ],
                ));
      },
      child: Container(
        margin: EdgeInsets.only(left: 5),
        padding: EdgeInsets.only(top: 25, left: 21, right: 20, bottom: 25),
        height: 90,
        width: 91,
        color: Color.fromRGBO(101, 99, 255, 1),
        child: Icon(Icons.photo_camera_front_rounded),
      ),
    );
  }
}
