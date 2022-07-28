import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'library/call_notification.dart';
import 'package:http/http.dart' as http;
//背景或關閉時收到訊息
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('####Handling a background message ${message.notification?.title}');
  callNotification.showInComingNotification();
}
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (true) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
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
// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}
var callNotification=CallNotification();
class MyHomePage extends StatelessWidget {
  String? _token;
  BuildContext? buildContext;
  @override
  Widget build(BuildContext context) {


    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      print("####fcm1=$message");
      //callNotification.showInComingNotification();
      if (message != null) {
        // Navigator.pushNamed(
        //   context,
        //   '/message',
        //   arguments: MessageArguments(message, true),
        // );

      }
    });
    //前景收到訊息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("####fcm2=${message.notification?.body}");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && true) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      //callNotification.showInComingNotification();
      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
      print("####fcm3=$message");
    });
    FirebaseMessaging.instance
        .getToken(
        vapidKey:
        'AIzaSyAlgXpNz2f9a4YWTxjeUO0LxTfyJTubP9U')
        .then((token){print("####token=$_token");_token = token;sendPushMessage();});
    FirebaseMessaging.instance.subscribeToTopic('fcm_test');
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
                Future.delayed(Duration(seconds: 5),() async{
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
  Future<void> sendPushMessage() async {
    print("####token=2$_token");
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
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
