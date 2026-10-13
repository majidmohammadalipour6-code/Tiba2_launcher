import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

void main() {
  runApp(const TibaLauncherApp());
}

class TibaLauncherApp extends StatelessWidget {
  const TibaLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiba 2 Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0C14),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _timer;
  String _timeString = '';
  String _dateString = '';

  @override
  void initState() {
    super.initState();
    // این بخش باعث می‌شود برنامه دیگر کرش نکند و تنظیمات بعد از لود شدن اعمال شوند
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    if (mounted) {
      setState(() {
        _timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        _dateString = "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // --- متدهای اجرای برنامه‌ها ---
  void _openSettings() => const AndroidIntent(action: 'android.settings.SETTINGS', flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK]).launch();
  void _openDialer() => const AndroidIntent(action: 'android.intent.action.DIAL', flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK]).launch();
  void _openMaps() => const AndroidIntent(action: 'android.intent.action.VIEW', data: 'geo:0,0?q=', flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK]).launch();
  void _openMusic() => const AndroidIntent(action: 'android.intent.action.MAIN', category: 'android.intent.category.APP_MUSIC', flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK]).launch();

  void _showAllApps(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => FutureBuilder<List<AppInfo>>(
        future: InstalledApps.getInstalledApps(true, true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final apps = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemCount: apps.length,
            itemBuilder: (ctx, i) => InkWell(
              onTap: () { InstalledApps.startApp(apps[i].packageName!); Navigator.pop(ctx); },
              child: Column(children: [
                apps[i].icon != null ? Image.memory(apps[i].icon!, width: 40) : const Icon(Icons.android),
                Text(apps[i].name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10))
              ]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_timeString, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            Text(_dateString, style: const TextStyle(fontSize: 20)),
          ])),
          Expanded(child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(20),
            children: [
              _buildBtn(Icons.map, "Maps", _openMaps),
              _buildBtn(Icons.music_note, "Music", _openMusic),
              _buildBtn(Icons.dialpad, "Dial", _openDialer),
              _buildBtn(Icons.apps, "Apps", () => _showAllApps(context)),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildBtn(IconData icon, String label, VoidCallback onTap) => Card(
    child: InkWell(onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 40), Text(label)])),
  );
}
