// lib/controllers/dashboard_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/mqtt_service.dart';
import '../models/telemetry_model.dart';

class DashboardController extends ChangeNotifier {
  late MqttService _mqttService;

  bool isConnected = false;
  bool isConnecting = false; // Indikator loading saat mencoba connect
  
  TelemetryModel data = TelemetryModel(
    temperature: 0.0,
    humidity: 0.0,
    fanState: false,
    setpoint: 30.0,
    mode: "AUTO",
  );

  final List<FlSpot> tempSpots = [];
  final List<FlSpot> humSpots = [];
  double _xValue = 0;

  final String topicTelemetry = "iotcoba/imam/telemetry";
  final String topicSetpoint = "iotcoba/imam/setpoint";
  final String topicFan = "iotcoba/imam/fan";
  final String topicMode = "iotcoba/imam/mode";

  DashboardController() {
    _mqttService = MqttService(
      onConnected: _onConnected,
      onDisconnected: _onDisconnected,
      onMessageReceived: _onMessageReceived,
    );
    // HAPUS _mqttService.connect(); dari sini agar tidak otomatis jalan
  }

  // Fungsi baru untuk menghubungkan berdasarkan inputan
  Future<void> connect(String serverAddress) async {
    isConnecting = true;
    notifyListeners();
    
    await _mqttService.connect(serverAddress);
    
    isConnecting = false;
    notifyListeners();
  }

  // Fungsi baru untuk memutuskan koneksi
  void disconnect() {
    _mqttService.disconnect();
  }

  void _onConnected() {
    isConnected = true;
    notifyListeners();
  }

  void _onDisconnected() {
    isConnected = false;
    notifyListeners();
  }

 void _onMessageReceived(String topic, String payload) {
    // Gunakan .trim() untuk membuang spasi kosong yang mungkin terbawa dari MQTT
    String cleanTopic = topic.trim();
    
    if (cleanTopic == topicTelemetry.trim()) {
      try {
        final decoded = jsonDecode(payload);
        data = TelemetryModel.fromJson(decoded);

        // Update koordinat grafik
        _xValue += 1;
        tempSpots.add(FlSpot(_xValue, data.temperature));
        humSpots.add(FlSpot(_xValue, data.humidity));

        if (tempSpots.length > 20) {
          tempSpots.removeAt(0);
          humSpots.removeAt(0);
        }
        
        // Memicu UI untuk menggambar ulang dengan data terbaru
        notifyListeners();
        
        print("UI Berhasil Diperbarui! Suhu: ${data.temperature} | Kelembapan: ${data.humidity}");
      } catch (e) {
        print('Error Parsing JSON Telemetry: $e');
      }
    } else if (cleanTopic == topicFan.trim()) {
      data = TelemetryModel(
        temperature: data.temperature,
        humidity: data.humidity,
        setpoint: data.setpoint,
        mode: data.mode,
        fanState: (payload.trim() == "ON"),
      );
      notifyListeners();
      print("UI Kipas Diperbarui -> Status: ${data.fanState}");
    }
  }

  void setMode(String newMode) {
    _mqttService.publishMessage(topicMode, newMode);
  }

  void updateSetpoint(double newSetpoint) {
    _mqttService.publishMessage(topicSetpoint, newSetpoint.toStringAsFixed(1));
  }

  void controlFan(bool turnOn) {
    _mqttService.publishMessage(topicFan, turnOn ? "ON" : "OFF");
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }
}