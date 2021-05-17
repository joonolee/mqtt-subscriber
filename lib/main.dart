import 'package:flutter/material.dart';

import 'common/mqtt_manager.dart';

final mqttManager =
    MqttManager(host: 'test.mosquitto.org', topic: 'diaconn/jhlee9652', identifier: 'jhlee2');
void main() {
  mqttManager.initializeMQTTClient();
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('MQTT 메시지를 수신하고 있습니다.')],
        ),
      ),
    );
  }
}
