import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

class CallNotification{
  var _currentUuid="";
  var _uuid = Uuid();
  Function(String)? callListener=null;

  //Single Object 確保整個app都使用到同一個物件
  static final CallNotification _singleton = CallNotification._internal();
  factory CallNotification() {
    return _singleton;
  }
  CallNotification._internal();

  //綁定要更新ui的callback方法
  void setCallListener(Function(String)? callListener){
    listenerEvent();
    this.callListener=callListener;
  }

  //顯示來電
  void showInComingNotification() async{
    print("####接聽");

      this._currentUuid = _uuid.v4();
      var params = <String, dynamic>{
        'id': _currentUuid,
        'nameCaller': 'Hien Nguyen',
        'appName': 'Callkit',
        'avatar': 'https://i.pravatar.cc/100',
        'handle': '0123456789',
        'type': 0,
        'textAccept': 'Accept',
        'textDecline': 'Decline',
        'textMissedCall': 'Missed call',
        'textCallback': 'Call back',
        'duration': 30000,
        'extra': <String, dynamic>{'userId': '1a2b3c4d'},
        'headers': <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
        'android': <String, dynamic>{
          'isCustomNotification': true,
          'isShowLogo': false,
          'isShowCallback': false,
          'isShowMissedCallNotification': true,
          'ringtonePath': 'system_ringtone_default',
          'backgroundColor': '#0955fa',
          'backgroundUrl': 'https://i.pravatar.cc/500',
          'actionColor': '#4CAF50'
        },
        'ios': <String, dynamic>{
          'iconName': 'CallKitLogo',
          'handleType': 'generic',
          'supportsVideo': false,
          'maximumCallGroups': 2,
          'maximumCallsPerCallGroup': 1,
          'audioSessionMode': 'default',
          'audioSessionActive': false,
          'audioSessionPreferredSampleRate': 44100.0,
          'audioSessionPreferredIOBufferDuration': 0.005,
          'supportsDTMF': false,
          'supportsHolding': false,
          'supportsGrouping': false,
          'supportsUngrouping': false,
          'ringtonePath': 'system_ringtone_default'
        }
      };
      await FlutterCallkitIncoming.showCallkitIncoming(params);

  }

  //初始化call的各種CallBack
  Future<void> listenerEvent() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      FlutterCallkitIncoming.onEvent.listen((event) {
        if(callListener!=null)callListener!(event!.name);
        // switch (event!.name) {
        //   case CallEvent.ACTION_CALL_INCOMING:
        //     print("####接到來電");
        //     break;
        //   case CallEvent.ACTION_CALL_START:
        //   // TODO: started an outgoing call
        //   // TODO: show screen calling in Flutter
        //     break;
        //   case CallEvent.ACTION_CALL_ACCEPT:
        //     print("####接起來店");
        //     break;
        //   case CallEvent.ACTION_CALL_DECLINE:
        //     print("####拒絕來電");
        //     break;
        //   case CallEvent.ACTION_CALL_ENDED:
        //   // TODO: ended an incoming/outgoing call
        //     break;
        //   case CallEvent.ACTION_CALL_TIMEOUT:
        //   // TODO: missed an incoming call
        //     break;
        //   case CallEvent.ACTION_CALL_CALLBACK:
        //   // TODO: only Android - click action `Call back` from missed call notification
        //     break;
        //   case CallEvent.ACTION_CALL_TOGGLE_HOLD:
        //   // TODO: only iOS
        //     break;
        //   case CallEvent.ACTION_CALL_TOGGLE_MUTE:
        //   // TODO: only iOS
        //     break;
        //   case CallEvent.ACTION_CALL_TOGGLE_DMTF:
        //   // TODO: only iOS
        //     break;
        //   case CallEvent.ACTION_CALL_TOGGLE_GROUP:
        //   // TODO: only iOS
        //     break;
        //   case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
        //   // TODO: only iOS
        //     break;
        //   case CallEvent.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
        //   // TODO: only iOS
        //     break;
        // }
      });
    }catch(e){
      print(e);
    }
    //沒加這行，ios將在接受第一次的上方訊息通知後，之後會自己開啟插件提供的畫面
    await FlutterCallkitIncoming.endAllCalls();
  }
}