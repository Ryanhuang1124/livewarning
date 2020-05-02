import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:livewarning/tools/content_builder.dart';
import 'package:livewarning/tools/house_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:simple_search_bar/simple_search_bar.dart';

class ContentPage extends StatefulWidget {
  final String muraName;

  const ContentPage({Key key, this.muraName}) : super(key: key);

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final TextEditingController noteController = TextEditingController();
  final fireStore = Firestore.instance;
  final FocusNode _nodeText1 = FocusNode();
  List<HouseObj> filtedList = null;

  String _status;

  ScrollController _myScrollbarController = ScrollController();

  TextEditingController editingController = TextEditingController();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Color.fromRGBO(88, 88, 88, 1),
      nextFocus: false,
      actions: [
        KeyboardAction(
          focusNode: _nodeText1,
        ),
      ],
    );
  }

  Future<void> _launchUniversalLinkIos(String url) async {
    if (await canLaunch(url)) {
      final bool nativeAppLaunchSucceeded = await launch(
        url,
        forceSafariVC: false,
        universalLinksOnly: true,
      );
      if (!nativeAppLaunchSucceeded) {
        await launch(
          url,
          forceSafariVC: true,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: fireStore
            .collection('HouseData')
            .document(widget.muraName)
            .snapshots(),
        builder: (context, snapshot) {
          List<HouseObj> insList = [];
          List<HouseObj> unList = [];

          if (snapshot.hasData) {
            snapshot.data.data.forEach((k, v) {
              HouseObj obj = new HouseObj();
              //k=address
              //v[0] = Lat , Lot
              //v[1] = no.
              //v[2] = optional status
              //v[3] = note
              //v[4] = installed by who
              obj.address = k;
              obj.muraID = widget.muraName;
              obj.geo = v[0];
              obj.number = v[1];
              obj.status = v[2];
              obj.note = v[3];
              obj.installed = v[4];
              if (obj.status != '未安裝') {
                insList.add(obj);
              } else {
                unList.add(obj);
              }
            });
            insList.sort((a, b) => a.number.compareTo(b.number)); //List排序 從小到大
            unList.sort((a, b) => a.number.compareTo(b.number));

            List<HouseObj> objList = unList + insList;
            return Container(
              decoration:
                  BoxDecoration(color: Color.fromRGBO(246, 247, 249, 1)),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text(
                        '${insList.length}  /  ${objList.length}     Installed',
                        style: TextStyle(fontFamily: 'LilitaOne', fontSize: 20),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.height * 0.02,
                        right: MediaQuery.of(context).size.height * 0.02,
                        top: MediaQuery.of(context).size.height * 0.02),
                    child: Container(
                      child: TextField(
                        onChanged: (input) {
                          filtedList = searchResult(objList, input);
                          setState(() {});
                        },
                        keyboardType: TextInputType.text,
                        controller: editingController,
                        decoration: InputDecoration(
                            labelText: "輸入地址",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)))),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Expanded(
                    child: DraggableScrollbar.semicircle(
                      controller: _myScrollbarController,
                      child: ListView.builder(
                        controller: _myScrollbarController,
                        itemCount: filtedList == null
                            ? objList.length
                            : filtedList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.02,
                                left: MediaQuery.of(context).size.width * 0.04,
                                right: MediaQuery.of(context).size.width * 0.04,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.02),
                            child: Opacity(
                              opacity: filtedList == null
                                  ? (objList[index].status != '未安裝' ? 0.5 : 1)
                                  : (filtedList[index].status != '未安裝'
                                      ? 0.5
                                      : 1),
                              child: GestureDetector(
                                onTap: () {
                                  EasyDialog(
                                      closeButton: false,
                                      cardColor: Colors.white,
                                      cornerRadius: 15.0,
                                      fogOpacity: 0.1,
                                      width: MediaQuery.of(context).size.width /
                                          1.568,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3.2,
                                      contentPadding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
                                                70.83,
                                      ), // Needed for the button design
                                      contentList: [
                                        Expanded(
                                          child: StatefulBuilder(
                                            builder: (context, setState) {
                                              return Column(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Padding(
                                                            padding: EdgeInsets.only(
                                                                left: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    30)),
                                                        Text(
                                                          "輸入資訊",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'Yuanti',
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  23.05),
                                                          textScaleFactor: 1.3,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            20,
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                20),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .greenAccent,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                                child:
                                                                    DropdownButton(
                                                          items: <
                                                              DropdownMenuItem>[
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '未安裝',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '未安裝',
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '已安裝',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '已安裝',
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '拒裝',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '拒裝',
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '訪視無人',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '訪視無人',
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '搬離',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '搬離',
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '安置機構',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '安置機構',
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '拆除',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '拆除',
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '空屋',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '空屋',
                                                            ),
                                                            DropdownMenuItem(
                                                              child: Center(
                                                                child: Text(
                                                                  '往生',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Yuanti',
                                                                      fontSize:
                                                                          22,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              18,
                                                                              18,
                                                                              18,
                                                                              1)),
                                                                ),
                                                              ),
                                                              value: '往生',
                                                            ),
                                                          ],
                                                          hint: Text(
                                                            '請選擇',
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        18,
                                                                        18,
                                                                        18,
                                                                        1)),
                                                          ),
                                                          onChanged: (value) {
                                                            _status = value;
                                                            setState(() {});
                                                          },
                                                          value: _status,
                                                          elevation: 24,
                                                          style: new TextStyle(
                                                            fontFamily:
                                                                'Yuanti',
                                                            color: Colors.white,
                                                            fontSize: 22,
                                                          ),
                                                          icon: Icon(Icons
                                                              .arrow_drop_down),
                                                          iconSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              20,
                                                          iconEnabledColor:
                                                              Color.fromRGBO(18,
                                                                  18, 18, 1),
                                                        )),
                                                      ),
                                                    ],
                                                  )),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Padding(
                                                            padding: EdgeInsets.only(
                                                                left: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    30)),
                                                        Text(
                                                          "備註",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'Yuanti',
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  23.05),
                                                          textScaleFactor: 1.3,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              20),
                                                      child: KeyboardActions(
                                                        config: _buildConfig(
                                                            context),
                                                        child: TextField(
                                                          onChanged: (data) {},
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          focusNode: _nodeText1,
                                                          controller:
                                                              noteController,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText:
                                                                  '點此填寫備註'),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            100,
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .greenAccent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                              ),
                                                            ),
                                                            child: FlatButton(
                                                              child: Text(
                                                                "Cancel",
                                                                textScaleFactor:
                                                                    1.6,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'LilitaOne',
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        24.5),
                                                              ),
                                                              onPressed: () {
                                                                _status = null;
                                                                noteController
                                                                    .clear();
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 1,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .greenAccent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                              ),
                                                            ),
                                                            child: FlatButton(
                                                              child: Text(
                                                                "OK",
                                                                textScaleFactor:
                                                                    1.6,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'LilitaOne',
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        24.5),
                                                              ),
                                                              onPressed: () {
                                                                setState(() {});
                                                                if (filtedList ==
                                                                    null) {
                                                                  objList[index]
                                                                          .status =
                                                                      _status;
                                                                  if (noteController
                                                                          .text
                                                                          .length !=
                                                                      0) {
                                                                    objList[index]
                                                                            .note =
                                                                        noteController
                                                                            .text;
                                                                  }
                                                                  if (objList[index]
                                                                          .status !=
                                                                      null) {
                                                                    uploadDialogData(
                                                                        objList[
                                                                            index]);
                                                                  }
                                                                } else {
                                                                  filtedList[index]
                                                                          .status =
                                                                      _status;
                                                                  if (noteController
                                                                          .text
                                                                          .length !=
                                                                      0) {
                                                                    filtedList[index]
                                                                            .note =
                                                                        noteController
                                                                            .text;
                                                                  }
                                                                  if (filtedList[
                                                                              index]
                                                                          .status !=
                                                                      null) {
                                                                    uploadDialogData(
                                                                        filtedList[
                                                                            index]);
                                                                  }
                                                                }

                                                                noteController
                                                                    .clear();
                                                                _status = null;
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        )
                                      ]).show(context);
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.18,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        spreadRadius: 3,
                                        offset: Offset(3, 3),
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    top: 10,
                                                    bottom: 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      color: Color.fromRGBO(
                                                          251, 235, 204, 1)),
                                                  child: Center(
                                                      child: Text(
                                                    filtedList == null
                                                        ? (objList[index]
                                                            .number
                                                            .toString())
                                                        : (filtedList[index]
                                                            .number
                                                            .toString()),
                                                    style: TextStyle(
                                                        fontFamily: 'LilitaOne',
                                                        fontSize: 28),
                                                  )),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01,
                                            ),
                                            Expanded(
                                                flex: 4,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      251,
                                                                      235,
                                                                      204,
                                                                      1),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10))),
                                                          child: Center(
                                                            child: Text(
                                                              filtedList == null
                                                                  ? (objList[
                                                                          index]
                                                                      .address)
                                                                  : (filtedList[
                                                                          index]
                                                                      .address),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Yuanti',
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                                flex: 3,
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.03),
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              '狀態 : ${filtedList == null ? (objList[index].status) : (filtedList[index].status)}',
                                                                              style: TextStyle(
                                                                                fontSize: 15,
                                                                                fontFamily: 'Yuanti',
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              '安裝人 : ${filtedList == null ? (objList[index].installed) : (filtedList[index].installed)}',
                                                                              style: TextStyle(
                                                                                fontSize: 15,
                                                                                fontFamily: 'Yuanti',
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        child:
                                                                            Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              '備註 : ${filtedList == null ? (objList[index].note) : (filtedList[index].note)}',
                                                                              style: TextStyle(
                                                                                fontSize: 15,
                                                                                fontFamily: 'Yuanti',
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                            Expanded(
                                                              flex: 1,
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  String
                                                                      toLaunch =
                                                                      'https://www.google.com/maps/dir/?api=1&destination='
                                                                      '${filtedList == null ? objList[index].geo.latitude : filtedList[index].geo.latitude},'
                                                                      '${filtedList == null ? objList[index].geo.longitude : filtedList[index].geo.longitude}'
                                                                      '&travelmode=driving';
                                                                  print(
                                                                      toLaunch);
                                                                  _launchUniversalLinkIos(
                                                                      toLaunch);
                                                                },
                                                                child:
                                                                    Container(
                                                                  child: Image
                                                                      .asset(
                                                                    'images/Navigation.png',
                                                                    scale: 11,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              color: Color.fromRGBO(246, 247, 249, 1),
              child: SpinKitRing(
                color: Color.fromRGBO(45, 0, 118, 1),
                size: 60,
              ),
            );
          }
        });
  }
}
