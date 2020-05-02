import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livewarning/tools/house_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

//upload name,note,status

void uploadDialogData(HouseObj obj) async {
  final fireStore = Firestore.instance;
  SharedPreferences pref = await SharedPreferences.getInstance();
  String userName = pref.get('userName');

  List temp = [];
  temp.add(obj.geo);
  temp.add(obj.number);
  temp.add(obj.status);
  temp.add(obj.note);
  temp.add(userName);

  await fireStore
      .collection('HouseData')
      .document(obj.muraID)
      .setData({obj.address: temp}, merge: true);
}

List<HouseObj> searchResult(List<HouseObj> originalList, String input) {
  List<HouseObj> result = [];

  if (input.isNotEmpty) {
    originalList.forEach((item) {
      if (item.address.contains(input)) {
        result.add(item);
      }
    });
    return result;
  } else {
    return null;
  }
}

void handJobUploader() async {
  final fireStore = Firestore.instance;
  List<double> lat3 = [];
  List<double> lot3 = [];
  List<String> address = [];

  List<GeoPoint> geoPoint = [];
  for (int i = 0; i < lat3.length; i++) {
    GeoPoint temp = new GeoPoint(lat3[i], lot3[i]);
    geoPoint.add(temp);
  }

  print('lot${lot3.length}');
  print('lat${lat3.length}');
  print('geo${geoPoint.length}');
  print('addres${address.length}');

  for (int i = 0; i < address.length; i++) {
    List temp = new List();
    temp.add(geoPoint[i]);
    temp.add(349 + i);
    temp.add('未安裝');
    temp.add('');
    temp.add('');

    print('i:${349 + i}  geo:${geoPoint[i].longitude} adress:${address[i]}');
    await fireStore
        .collection('HouseData')
        .document('月眉村')
        .setData({address[i]: temp}, merge: true);
  }
}
