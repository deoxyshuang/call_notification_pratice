import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'library/call_notification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
var callNotification=CallNotification();
class MyHomePage extends StatelessWidget {

  BuildContext? buildContext;
  @override
  Widget build(BuildContext context) {
    buildContext=context;
    callNotification.setCallListener(callListener);
    return Scaffold(
      appBar: AppBar(
        title: Text("播打測試"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              color: Colors.red,
              child: Text("3秒後來電測試",style: TextStyle(fontSize: 40,color: Colors.white),),
              onPressed: () {
                Future.delayed(Duration(seconds: 3),() async{
                  callNotification.showInComingNotification();
                });

             },
            ),
            MaterialButton(
              color: Colors.blue,
              child: Text("取消來電",style: TextStyle(fontSize: 40,color: Colors.white),),
              onPressed: () {
                callNotification.cancelInComingNotification();

              },
            ),
          ],
        ),
      ),
    );
  }
  //監聽call相關事件
  void callListener(String action){
    print("####action=$action");
    switch (action) {
      case CallEvent.ACTION_CALL_INCOMING:
        print("####接到來電");
        break;
      case CallEvent.ACTION_CALL_ACCEPT:
        print("####接起來電");
        Navigator.push(buildContext!, MaterialPageRoute(builder: (context) => MyHomePage()));
        break;
      case CallEvent.ACTION_CALL_DECLINE:
        print("####拒絕來電1");
        break;
      case CallEvent.ACTION_CALL_ENDED:
        print("####拒絕來電2");
        break;
    }
  }
}
