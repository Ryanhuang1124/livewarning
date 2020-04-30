import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:beauty_textfield/beauty_textfield.dart';
import 'package:livewarning/pages/main_page.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:livewarning/tools/login_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final fireStore = Firestore.instance;
  Future<List<UserData>> userList;
  String inputID = '';
  @override
  void initState() {
    super.initState();
    userList = getMemberID(fireStore);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color.fromRGBO(66, 147, 175, 1),
                Color.fromRGBO(51, 8, 103, 1),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    Container(
                      child: Center(
                        child: ColorizeAnimatedTextKit(
                          speed: Duration(milliseconds: 800),
                          totalRepeatCount: double.infinity,
                          onTap: () {},
                          text: ['ShouFeng'],
                          textStyle:
                              TextStyle(fontSize: 70, fontFamily: 'Pacifico'),
                          colors: [
                            Colors.white,
                            Colors.blue,
                            Colors.red,
                            Colors.yellow,
                          ],
                          textAlign: TextAlign.start,
                          alignment: AlignmentDirectional.topStart,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                    ),
                    Container(
                      child: Center(
                          child: Text(
                        'Loggin',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Courgette',
                            fontSize: 30),
                      )),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 7,
                    ),
                    BeautyTextfield(
                      width: MediaQuery.of(context).size.width / 1.25,
                      height: MediaQuery.of(context).size.height / 13,
                      duration: Duration(milliseconds: 600),
                      inputType: TextInputType.number,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: Icon(Icons.highlight),
                      placeholder: "手機號碼",
                      fontFamily: 'Yuanti',
                      fontWeight: FontWeight.w200,
                      isShadow: true,
                      onTap: () {},
                      onChanged: (text) {
                        inputID = text;
                      },
                      onSubmitted: (data) {},
                      onClickSuffix: () {},
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 7,
                    ),
                    FutureBuilder<List<UserData>>(
                      future: userList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          String userName = '';
                          return Container(
                            width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.height / 13,
                            child: ProgressButton(
                              color: Color.fromRGBO(66, 39, 122, 1),
                              progressIndicatorColor: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              strokeWidth: 10,
                              child: Text(
                                "Log  in",
                                style: TextStyle(
                                  fontFamily: 'LilitaOne',
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                              ),
                              onPressed:
                                  (AnimationController controller) async {
                                controller.forward();
                                bool isCorrect = false;
                                for (var obj in snapshot.data) {
                                  if (obj.id == inputID) {
                                    isCorrect = true;
                                    userName = obj.name;
                                  }
                                }
                                if (isCorrect == false) {
                                  await Future.delayed(
                                    Duration(milliseconds: 1500),
                                  );
                                  BotToast.showCustomText(
                                    toastBuilder: (_) => Align(
                                      alignment: Alignment(0, 0.8),
                                      child: Card(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            '你可能打錯了哦..',
                                            style: TextStyle(
                                              fontFamily: 'Yuanti',
                                              fontSize: 24,
                                              color: Color.fromRGBO(
                                                  66, 39, 122, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    duration: Duration(seconds: 3),
                                    onlyOne: true,
                                    clickClose: true,
                                    ignoreContentClick: true,
                                  );
                                  controller.reverse();
                                } else {
                                  setUserCache(true, userName);
                                  await Future.delayed(
                                    Duration(milliseconds: 1500),
                                  );
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MainPage()));
                                }
                              },
                            ),
                          );
                        }
                        return Container(
                          child: SpinKitThreeBounce(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 4,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
