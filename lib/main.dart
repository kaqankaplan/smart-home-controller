import 'package:flutter/material.dart';
import 'models/smart_device.dart';

void main() => runApp(const SmartHomeApp());

const background = Color(0xFF10151D);
const surface = Color(0xFF1B2330);
const muted = Color(0xFF9CAAC0);
const mint = Color(0xFF9DE6CE);

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smart Home Controller',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mint,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      sliderTheme: const SliderThemeData(
        trackHeight: 4,
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SmartLight light;
  late final Thermostat thermostat;
  late final SmartSpeaker speaker;
  late final List<SmartDevice> devices;

  @override
  void initState() {
    super.initState();
    // Instantiate devices once. Both unnamed and named constructors are used.
    light = SmartLight(name: 'Smart Light', room: 'Living room');
    thermostat = Thermostat.comfort(room: 'Bedroom');
    speaker = SmartSpeaker(name: 'Smart Speaker', room: 'Kitchen');
    devices = [light, thermostat, speaker];
    for (final device in devices) {
      device.connect();
    }
  }

  @override
  void dispose() {
    light.clearSchedule();
    super.dispose();
  }

  void update(VoidCallback action) => setState(action);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mint,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: background,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'H O M E / C O N T R O L',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'My smart home',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF25433E), Color(0xFF1C2D36)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: mint.withValues(alpha: .16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.circle, color: mint, size: 8),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'CONNECTED & IN CONTROL',
                                  style: TextStyle(
                                    color: mint,
                                    fontSize: 10,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'A little more comfort.',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Your favorite spaces, one touch away.',
                            style: TextStyle(
                              color: Color(0xFFC0D0D0),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 24,
                            runSpacing: 8,
                            children: [
                              Text(
                                '${devices.where((d) => d.isConnected).length} devices online',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                '${thermostat.temperature.round()}°C target',
                                style: const TextStyle(
                                  color: mint,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Your devices',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DeviceCard(
                      device: light,
                      icon: Icons.lightbulb_outline_rounded,
                      accent: const Color(0xFFF5CF86),
                      trailing: Semantics(
                        label: 'Toggle smart light',
                        child: Switch(
                          value: light.isOn,
                          onChanged: (_) => update(light.performAction),
                        ),
                      ),
                      child: Column(
                        children: [
                          metric('Brightness', '${light.brightness}%'),
                          Slider(
                            value: light.brightness.toDouble(),
                            min: 1,
                            max: 100,
                            divisions: 99,
                            label: '${light.brightness}%',
                            semanticFormatterCallback: (v) =>
                                '${v.round()} percent brightness',
                            activeColor: const Color(0xFFF5CF86),
                            onChanged: light.isOn
                                ? (v) => update(
                                    () => light.setBrightness(v.round()),
                                  )
                                : null,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: muted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  light.scheduleLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: muted,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => update(() {
                                  if (light.hasSchedule) {
                                    light.clearSchedule();
                                  } else {
                                    light.scheduleAfter(
                                      const Duration(minutes: 1),
                                      () {
                                        if (mounted) {
                                          update(() => light.setPower(false));
                                        }
                                      },
                                    );
                                  }
                                }),
                                child: Text(
                                  light.hasSchedule ? 'Cancel' : 'Off in 1 min',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    DeviceCard(
                      device: thermostat,
                      icon: Icons.thermostat_rounded,
                      accent: const Color(0xFFB9AEF8),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            temperatureButton(
                              Icons.remove,
                              'Decrease temperature',
                              thermostat.temperature > Thermostat.minTemperature
                                  ? () => update(
                                      () => thermostat.adjustTemperature(-1),
                                    )
                                  : null,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${thermostat.temperature.round()}°',
                                    style: const TextStyle(
                                      fontSize: 46,
                                      fontWeight: FontWeight.w500,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const FittedBox(
                                    child: Text(
                                      'TARGET TEMPERATURE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: 1.2,
                                        color: muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            temperatureButton(
                              Icons.add,
                              'Increase temperature',
                              thermostat.temperature < Thermostat.maxTemperature
                                  ? () => update(
                                      () => thermostat.adjustTemperature(1),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DeviceCard(
                      device: speaker,
                      icon: Icons.speaker_outlined,
                      accent: const Color(0xFF8BC9F0),
                      trailing: IconButton.filled(
                        onPressed: () => update(speaker.performAction),
                        tooltip: speaker.isPlaying
                            ? 'Pause speaker'
                            : 'Play speaker',
                        icon: Icon(
                          speaker.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                      child: Column(
                        children: [
                          metric('Volume', '${speaker.volume}%'),
                          Row(
                            children: [
                              const Icon(
                                Icons.volume_down_rounded,
                                size: 20,
                                color: muted,
                              ),
                              Expanded(
                                child: Slider(
                                  value: speaker.volume.toDouble(),
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  label: '${speaker.volume}%',
                                  semanticFormatterCallback: (v) =>
                                      '${v.round()} percent volume',
                                  activeColor: const Color(0xFF8BC9F0),
                                  onChanged: (v) => update(
                                    () => speaker.setVolume(v.round()),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.volume_up_rounded,
                                size: 20,
                                color: muted,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Demo home · Device states are simulated',
                        style: TextStyle(color: muted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.devices_other_rounded,
                      size: 20,
                      color: mint,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Total devices',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                    const Spacer(),
                    // Static class variable, rather than a hardcoded UI count.
                    Text(
                      '${SmartDevice.totalDevices}',
                      key: const Key('total-device-count'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: mint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget metric(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: muted, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  Widget temperatureButton(
    IconData icon,
    String tooltip,
    VoidCallback? action,
  ) => IconButton.outlined(
    onPressed: action,
    tooltip: tooltip,
    style: IconButton.styleFrom(
      fixedSize: const Size(48, 48),
      side: const BorderSide(color: Color(0xFF3A4253)),
    ),
    icon: Icon(icon),
  );
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.icon,
    required this.accent,
    required this.child,
    this.trailing,
  });
  final SmartDevice device;
  final IconData icon;
  final Color accent;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF2B3443)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.room.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      color: muted,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    device.getStatus(),
                    style: TextStyle(fontSize: 12, color: accent),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
        child,
      ],
    ),
  );
}
