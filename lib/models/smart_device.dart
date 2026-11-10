import 'dart:async';

/// A contract implemented by SmartDevice and inherited by all device classes.
abstract interface class Connectable {
  void connect();
  void disconnect();
}

/// Reusable timer behavior, mixed into SmartLight.
mixin Schedulable {
  Timer? _timer;
  bool get hasSchedule => _timer?.isActive ?? false;
  String get scheduleLabel =>
      hasSchedule ? 'Auto-off in 1 minute' : 'No timer set';

  void scheduleAfter(Duration delay, void Function() action) {
    clearSchedule();
    _timer = Timer(delay, action);
  }

  void clearSchedule() {
    _timer?.cancel();
    _timer = null;
  }
}

abstract class SmartDevice implements Connectable {
  static int _totalDevices = 0;
  static int get totalDevices => _totalDevices;
  final String name;
  final String room;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  SmartDevice({required this.name, required this.room}) {
    _totalDevices++;
  }

  @override
  void connect() => _isConnected = true;
  @override
  void disconnect() => _isConnected = false;

  String getStatus();
  void performAction();
}

class SmartLight extends SmartDevice with Schedulable {
  bool _isOn = true;
  int _brightness = 75;
  bool get isOn => _isOn;
  int get brightness => _brightness;

  SmartLight({required super.name, required super.room});
  void setPower(bool value) => _isOn = value;
  void setBrightness(int value) => _brightness = value.clamp(1, 100);
  @override
  void performAction() => _isOn = !_isOn;
  @override
  String getStatus() => _isOn ? 'On' : 'Off';
}

class Thermostat extends SmartDevice {
  static const double minTemperature = 16;
  static const double maxTemperature = 30;
  double _temperature;
  double get temperature => _temperature;

  Thermostat({
    required super.name,
    required super.room,
    double temperature = 22,
  }) : _temperature = temperature.clamp(minTemperature, maxTemperature);

  /// Named constructor delegates to the unnamed constructor with `this`.
  Thermostat.comfort({required String room})
    : this(name: 'Thermostat', room: room, temperature: 22);

  void adjustTemperature(double change) {
    _temperature = (_temperature + change).clamp(
      minTemperature,
      maxTemperature,
    );
  }

  @override
  String getStatus() => _temperature > 22
      ? 'Heating'
      : _temperature < 22
      ? 'Cooling'
      : 'Comfort';
  @override
  void performAction() => adjustTemperature(1);
}

class SmartSpeaker extends SmartDevice {
  bool _isPlaying = false;
  int _volume = 40;
  bool get isPlaying => _isPlaying;
  int get volume => _volume;

  SmartSpeaker({required super.name, required super.room});
  void setVolume(int value) => _volume = value.clamp(0, 100);
  @override
  void performAction() => _isPlaying = !_isPlaying;
  @override
  String getStatus() => _isPlaying ? 'Playing' : 'Paused';
}
