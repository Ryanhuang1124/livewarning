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
