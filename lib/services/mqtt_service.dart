import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttService {
  MqttClient? _client;
  
  final Function() onConnected;
  final Function() onDisconnected;
  final Function(String topic, String payload) onMessageReceived;

  MqttService({
    required this.onConnected,
    required this.onDisconnected,
    required this.onMessageReceived,
  });

  // Tambahkan parameter serverAddress
 Future<void> connect(String serverAddress) async {
    // 1. Buat Client ID yang lebih pendek (beberapa broker membatasi max 23 karakter)
    String clientId = 'fl_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    if (kIsWeb) {
      // 2. Format URL khusus untuk Web (WebSocket)
      String webSocketUrl = serverAddress;
      
      // Jika user hanya mengetik "broker.emqx.io", kita ubah menjadi "wss://broker.emqx.io/mqtt"
      if (!webSocketUrl.startsWith('ws://') && !webSocketUrl.startsWith('wss://')) {
        webSocketUrl = 'wss://$serverAddress/mqtt';
      }

      print("Mencoba koneksi Web ke URL: $webSocketUrl dengan port 8084");
      
      final browserClient = MqttBrowserClient(webSocketUrl, clientId);
      browserClient.port = 8084;
      browserClient.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
      _client = browserClient;
    } else {
      // 3. Format khusus untuk Mobile/Desktop (TCP)
      print("Mencoba koneksi Mobile ke URL: $serverAddress dengan port 1883");
      final serverClient = MqttServerClient(serverAddress, clientId);
      serverClient.port = 1883;
      _client = serverClient;
    }

    _client!.keepAlivePeriod = 60;
    _client!.logging(on: true); // KITA AKTIFKAN LOGGING SEMENTARA UNTUK MELIHAT ERROR DI CONSOLE
    _client!.onConnected = onConnected;
    _client!.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
      _setupListeners();
    } catch (e) {
      print('====================================');
      print('EXCEPTION KONEKSI MQTT: $e');
      print('====================================');
      _client!.disconnect();
      onDisconnected();
    }
  }

void _setupListeners() {
    print("Mencoba subscribe ke topik...");
    
    _client!.subscribe("iotcoba/imam/telemetry", MqttQos.atMostOnce);
    _client!.subscribe("iotcoba/imam/fan", MqttQos.atMostOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      for (var msg in c) {
        final MqttPublishMessage recMessage = msg.payload as MqttPublishMessage;
        
        // PERBAIKAN DI SINI:
        // Gunakan utf8.decode untuk menerjemahkan angka byte (ASCII) kembali menjadi teks JSON asli
        final String payload = utf8.decode(recMessage.payload.message);
        
        print('MQTT MASUK -> Topik: [${msg.topic}], Payload: $payload');
        
        onMessageReceived(msg.topic, payload);
      }
    });
  }

  void publishMessage(String topic, String message) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
  }

  void disconnect() {
    _client?.disconnect();
  }
}