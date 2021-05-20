import 'package:app_settings/app_settings.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'common/local_notification.dart';
import 'common/mqtt_manager.dart';

final mqttManager =
    MqttManager(host: 'test.mosquitto.org', topic: 'diaconn/jhlee9652', identifier: Uuid().v4());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());
  await LocalNotification.init();
  await mqttManager.initializeMQTTClient();
  mqttManager.connect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'MQTT 메시지 수신 앱'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _onBattery() async {
    if (await Permission.ignoreBatteryOptimizations.isGranted) {
      await AppSettings.openBatteryOptimizationSettings();
    } else {
      final PermissionStatus status = await Permission.ignoreBatteryOptimizations.request();
      if (status.isGranted) Fluttertoast.showToast(msg: '허용되었습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('MoveToBackground.moveTaskToBack()');
        await MoveToBackground.moveTaskToBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('MQTT수신로그는 아래 파일을 참조할것!'),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text('${mqttManager.file?.toString()}'),
              ),
              TextButton(
                onPressed: () => _onBattery(),
                child: Text('배터리 최적화 예외'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
