// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/sensor_card.dart';
import '../widgets/trend_chart.dart'; // Pastikan import sudah benar

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();
  final TextEditingController _serverController = TextEditingController(text: "broker.emqx.io");

  @override
  void dispose() {
    _controller.dispose();
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final data = _controller.data;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('ESP32 Dashboard (OOP)'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 6,
                      backgroundColor: _controller.isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(_controller.isConnected ? "Connected" : "Disconnected", 
                         style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PANEL KONEKSI SERVER
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Konfigurasi Server MQTT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _serverController,
                                enabled: !_controller.isConnected && !_controller.isConnecting,
                                decoration: const InputDecoration(
                                  labelText: "Alamat Server",
                                  border: OutlineInputBorder(),
                                  hintText: "contoh: broker.emqx.io",
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _controller.isConnected ? Colors.red : Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _controller.isConnecting
                                    ? null
                                    : () {
                                        if (_controller.isConnected) {
                                          _controller.disconnect();
                                        } else {
                                          if (_serverController.text.trim().isNotEmpty) {
                                            _controller.connect(_serverController.text.trim());
                                          }
                                        }
                                      },
                                child: _controller.isConnecting 
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(_controller.isConnected ? "Putus" : "Hubungkan"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (_controller.isConnected) ...[
                  // 1. Kartu Sensor
                  Row(
                    children: [
                      SensorCard(title: "Suhu", value: "${data.temperature.toStringAsFixed(1)} °C", icon: Icons.thermostat, color: Colors.orange),
                      SensorCard(title: "Kelembapan", value: "${data.humidity.toStringAsFixed(1)} %", icon: Icons.water_drop, color: Colors.blue),
                      SensorCard(
                        title: "Kipas",
                        value: data.fanState ? "ON" : "OFF",
                        icon: Icons.wind_power,
                        color: data.fanState ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. GRAFIK SUHU TERPISAH
                  TrendChart(
                    title: "Grafik Tren Suhu Ruangan",
                    spots: _controller.tempSpots,
                    lineColor: Colors.orange,
                    unit: "°C",
                  ),
                  const SizedBox(height: 16),

                  // 3. GRAFIK KELEMBAPAN TERPISAH
                  TrendChart(
                    title: "Grafik Tren Kelembapan Ruangan",
                    spots: _controller.humSpots,
                    lineColor: Colors.blue,
                    unit: "%",
                  ),
                  const SizedBox(height: 20),

                  // 4. Kontrol Mode
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Mode Kontrol", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ToggleButtons(
                            isSelected: [data.mode == "AUTO", data.mode == "MANUAL"],
                            onPressed: (index) => _controller.setMode(index == 0 ? "AUTO" : "MANUAL"),
                            borderRadius: BorderRadius.circular(8),
                            fillColor: Colors.teal,
                            selectedColor: Colors.white,
                            constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
                            children: const [Text("AUTO"), Text("MANUAL")],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Panel Dinamis (AUTO/MANUAL)
                  if (data.mode == "AUTO")
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Setpoint: ${data.setpoint.toStringAsFixed(1)} °C", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Slider(
                              value: data.setpoint, min: 0, max: 100, divisions: 100,
                              label: data.setpoint.toStringAsFixed(1),
                              onChanged: (_) {}, 
                              onChangeEnd: _controller.updateSetpoint,
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (data.mode == "MANUAL")
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () => _controller.controlFan(true),
                              icon: const Icon(Icons.power), label: const Text("NYALAKAN"),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              onPressed: () => _controller.controlFan(false),
                              icon: const Icon(Icons.power_off), label: const Text("MATIKAN"),
                            ),
                          ],
                        ),
                      ),
                    ),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Text(
                        "Silakan hubungkan ke server MQTT terlebih dahulu.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}