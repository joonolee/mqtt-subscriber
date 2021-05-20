import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:path_provider/path_provider.dart';

import 'local_notification.dart';

class MqttManager {
  // Private instance of client
  MqttServerClient _client;
  final String _identifier;
  final String _host;
  final String _topic;
  File file;

  Future<String> get _localPath async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    Fimber.d('localPath: ${directory.path}');
    return directory.path;
  }

  Future<void> get _localFile async {
    final path = await _localPath;
    file = File('$path/${DateFormat('yyyyMMdd').format(DateTime.now())}.txt');
  }

  Future<void> _writeDataToFile(String data) async {
    file?.writeAsStringSync(data, mode: FileMode.append, flush: true);
  }

  // Constructor
  MqttManager({@required String host, @required String topic, @required String identifier})
      : _identifier = identifier,
        _host = host,
        _topic = topic;

  Future<void> initializeMQTTClient() async {
    await _localFile; // 파일 생성
    _client = MqttServerClient(_host, _identifier);
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.onDisconnected = onDisconnected;
    _client.secure = false;
    _client.logging(on: true);
    _client.autoReconnect = true;

    /// Add the successful connection callback
    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    _client.connectionMessage = connMess;
  }

  // Connect to the host
  void connect() async {
    assert(_client != null);
    try {
      print('EXAMPLE::Mosquitto start client connecting....');
      await _client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    _client.disconnect();
  }

  Future<void> publish(String message) async {
    Fluttertoast.showToast(msg: '메시지 전송 : $message');
    await _writeDataToFile('${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}---> $message\n');
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client.connectionStatus.returnCode == MqttConnectReturnCode.noneSpecified) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
  }

  /// The successful connect callback
  void onConnected() {
    print('EXAMPLE::Mosquitto client connected....');
    _client.subscribe(_topic, MqttQos.atLeastOnce);
    _client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
      LocalNotification.show(title: 'MQTT 메시지 수신', body: pt);
      await _writeDataToFile('${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}<--- $pt\n');
    });
    print('EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}
