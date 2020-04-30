import 'package:flutter/material.dart';
import 'package:livewarning/pages/login_page.dart';
import 'package:livewarning/pages/main_page.dart';
import 'package:livewarning/tools/login_builder.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyWidget());
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Future<bool> futureIsLogin;

  void initState() {
    super.initState();
    futureIsLogin = getUserIsLogin();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return FutureBuilder(
      future: futureIsLogin,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool isLogin = snapshot.data;
          return BotToastInit(
            child: MaterialApp(
              navigatorObservers: [BotToastNavigatorObserver()],
              home: DefaultTabController(
                length: 1,
                child: isLogin ? MainPage() : LoginPage(),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
