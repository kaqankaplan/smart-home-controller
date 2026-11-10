import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_controller/models/smart_device.dart';

void main() {
  test('constructors count every created device exactly once', () {
    final before = SmartDevice.totalDevices;
    final devices = <SmartDevice>[
      SmartLight(name: 'Light', room: 'Living room'),
      Thermostat.comfort(room: 'Bedroom'),
      SmartSpeaker(name: 'Speaker', room: 'Kitchen'),
    ];
    expect(SmartDevice.totalDevices, before + 3);
    for (final device in devices) {
      expect(device, isA<Connectable>());
      device.connect();
      expect(device.isConnected, isTrue);
      device.disconnect();
      expect(device.isConnected, isFalse);
    }
    expect(SmartDevice.totalDevices, before + 3);
  });

  test('light action toggles power and brightness is bounded', () {
    final light = SmartLight(name: 'Light', room: 'Living room');
    light.performAction();
    expect(light.getStatus(), 'Off');
    light.performAction();
    expect(light.getStatus(), 'On');
    light.setBrightness(200);
    expect(light.brightness, 100);
    light.setBrightness(-1);
    expect(light.brightness, 1);
  });

  test('thermostat clamps temperature and reports its mode', () {
    final thermostat = Thermostat.comfort(room: 'Bedroom');
    expect(thermostat.temperature, 22);
    expect(thermostat.getStatus(), 'Comfort');
    thermostat.adjustTemperature(1);
    expect(thermostat.getStatus(), 'Heating');
    thermostat.adjustTemperature(100);
    expect(thermostat.temperature, 30);
    thermostat.adjustTemperature(-100);
    expect(thermostat.temperature, 16);
    expect(thermostat.getStatus(), 'Cooling');
  });

  test('speaker toggles playback and clamps volume', () {
    final speaker = SmartSpeaker(name: 'Speaker', room: 'Kitchen');
    expect(speaker.getStatus(), 'Paused');
    speaker.performAction();
    expect(speaker.getStatus(), 'Playing');
    speaker.setVolume(200);
    expect(speaker.volume, 100);
    speaker.setVolume(-10);
    expect(speaker.volume, 0);
  });

  testWidgets('mixin executes, replaces and cancels timers', (tester) async {
    final light = SmartLight(name: 'Light', room: 'Living room');
    light.scheduleAfter(
      const Duration(minutes: 1),
      () => light.setPower(false),
    );
    expect(light.hasSchedule, isTrue);
    await tester.pump(const Duration(minutes: 1));
    expect(light.isOn, isFalse);
    expect(light.hasSchedule, isFalse);
    light.setPower(true);
    light.scheduleAfter(
      const Duration(minutes: 1),
      () => light.setPower(false),
    );
    light.clearSchedule();
    await tester.pump(const Duration(minutes: 1));
    expect(light.isOn, isTrue);
    light.scheduleAfter(
      const Duration(seconds: 1),
      () => light.setPower(false),
    );
    light.scheduleAfter(
      const Duration(seconds: 2),
      () => light.setPower(false),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(light.isOn, isTrue);
    await tester.pump(const Duration(seconds: 1));
    expect(light.isOn, isFalse);
  });
}
