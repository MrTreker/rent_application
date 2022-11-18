import 'dart:async';

import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:rent_application/models/HomePhoneModel.dart';
import 'package:rent_application/repository/firestore_service.dart';
import 'package:rent_application/screens/notes/AddHomePhoneForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// The details screen for either the A or B screen.
class NoteHomePhoneDetailScreen extends StatefulWidget {
  /// Constructs a [NoteDetailScreen].
  const NoteHomePhoneDetailScreen({
    required this.label,
    required this.detailsHomePhonePath,
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

  /// The path to the detail page
  final String detailsHomePhonePath;

  @override
  State<StatefulWidget> createState() => NoteHomePhoneDetailScreenState();
}

//функция преобразования списка снапшотов коллекции в список сообщений
StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<HomePhoneModel>>
    documentToHomePhonesTransformer = StreamTransformer<
            QuerySnapshot<Map<String, dynamic>>,
            List<HomePhoneModel>>.fromHandlers(
        handleData: (QuerySnapshot<Map<String, dynamic>> snapShot,
            EventSink<List<HomePhoneModel>> sink) {
  List<HomePhoneModel> result = [];
  snapShot.docs.forEach((element) {
    FirestoreService.getHomePhones(element.id).then((value) {
      if (value != null) {
        result.add(HomePhoneModel(
          address: value['address'],
          code: value['code'],
        ));
        sink.add(result = List.from(result.reversed));
      }
    });
  });
  sink.add(result = List.from(result.reversed));
});

/// The state for DetailsScreen
class NoteHomePhoneDetailScreenState extends State<NoteHomePhoneDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Домофоны - Список домофонов'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('homePhones')
              .snapshots()
              .transform(documentToHomePhonesTransformer),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return _streamChatsWidget(context, snapshot.data);
              } else {
                return _emptyMessage();
              }
            }
            if (snapshot.hasError) {
              return Text('Произошла ошибка загрузки: ${snapshot.error}');
            }
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showDialog(
                context: context, builder: (context) => AddHomePhoneForm());
          });
        },
        //Beamer.of(context).beamToNamed(widget.detailsHomePhonePath),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _streamChatsWidget(context, List<HomePhoneModel> homephonesList) {
  if (homephonesList.length == 0) {
    return _emptyMessage();
  } else
    return ListView.builder(
        itemCount: homephonesList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        //
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: Text(
                          '${homephonesList[index].address}',
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2 - 2,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              child: Text('${homephonesList[index].code}',
                                  textAlign: TextAlign.center))),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
}

Widget _emptyMessage() {
  return Center(
    child: Container(
      child: Text(
        'Домофонов нет',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14.0),
      ),
    ),
  );
}
