// lib/models/telemetry_model.dart

class TelemetryModel {
  final double temperature;
  final double humidity;
  final bool fanState;
  final double setpoint;
  final String mode;

  TelemetryModel({
    required this.temperature,
    required this.humidity,
    required this.fanState,
    required this.setpoint,
    required this.mode,
  });

  // Factory pattern untuk parsing dari JSON
  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryModel(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      fanState: json['fan'] ?? false,
      setpoint: (json['setpoint'] as num?)?.toDouble() ?? 30.0,
      mode: json['mode'] ?? "AUTO",
    );
  }
}