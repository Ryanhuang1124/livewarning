import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:livewarning/pages/content_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final fireStore = Firestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: fireStore.collection('HouseData').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<String> muraList = [];
            List<Widget> tabList = [];
            List<Widget> contentList = [];

            snapshot.data.documents.forEach((k) {
              muraList.add(k.documentID);
            });
            for (var muraName in muraList) {
              contentList.add(ContentPage(muraName: muraName));
              tabList.add(
                Tab(
                  child: Row(
                    children: <Widget>[
                      Text(
                        muraName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Yuanti'),
                      )
                    ],
                  ),
                ),
              );
            }

            return DefaultTabController(
              length: tabList.length,
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Color.fromRGBO(246, 247, 249, 1),
                  title: Center(
                    child: Text(
                      'Smoke Alarm',
                      style: TextStyle(
                          fontSize: 37,
                          color: Color.fromRGBO(36, 0, 117, 1),
                          fontFamily: 'Pacifico'),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(
                        MediaQuery.of(context).size.height / 15),
                    child: TabBar(
                      labelColor: Color.fromRGBO(36, 0, 117, 1),
                      labelPadding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.15,
                          left: MediaQuery.of(context).size.width * 0.15),
                      isScrollable: true,
                      unselectedLabelColor: Color.fromRGBO(36, 0, 117, 0.3),
                      indicatorColor: Color.fromRGBO(36, 0, 117, 1),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 3,
                      tabs: tabList,
                    ),
                  ),
                ),
                body: TabBarView(children: contentList),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
