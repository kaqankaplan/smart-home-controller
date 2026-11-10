import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_controller/main.dart';
import 'package:smart_home_controller/models/smart_device.dart';

void main() {
  testWidgets(
    'three device controls update the UI without creating new devices',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1300));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final before = SmartDevice.totalDevices;
      await tester.pumpWidget(const SmartHomeApp());
      expect(find.text('Smart Light'), findsOneWidget);
      expect(find.text('Thermostat'), findsOneWidget);
      expect(find.text('Smart Speaker'), findsOneWidget);
      expect(SmartDevice.totalDevices, before + 3);
      expect(
        tester.widget<Text>(find.byKey(const Key('total-device-count'))).data,
        '${before + 3}',
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Off'), findsOneWidget);
      await tester.tap(find.byTooltip('Increase temperature'));
      await tester.pumpAndSettle();
      expect(find.text('23°'), findsOneWidget);
      expect(find.text('Heating'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Play speaker'));
      await tester.tap(find.byTooltip('Play speaker'));
      await tester.pumpAndSettle();
      expect(find.text('Playing'), findsOneWidget);
      expect(SmartDevice.totalDevices, before + 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('narrow screen supports scrolling and timer action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const SmartHomeApp());
    await tester.ensureVisible(find.text('Off in 1 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Off in 1 min'));
    await tester.pump();
    expect(find.text('Cancel'), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
    expect(find.text('Off'), findsOneWidget);
    expect(find.text('No timer set'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Play speaker'));
    expect(tester.takeException(), isNull);
  });
}
