import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
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
  String _timeString = '';
  double _currentSpeed = 0.0;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _initLocation();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = DateFormat('HH:mm').format(now);
    });
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      setState(() {
        _currentSpeed = position.speed >= 0 ? (position.speed * 3.6) : 0.0;
      });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // نوار دسترسی کناری
          Container(
            width: 75,
            color: const Color(0xFF111726),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.directions_car, color: Colors.cyanAccent, size: 34),
                IconButton(icon: const Icon(Icons.navigation, color: Colors.white70), onPressed: () {}),
                IconButton(icon: const Icon(Icons.music_note, color: Colors.white70), onPressed: () {}),
                IconButton(icon: const Icon(Icons.apps, color: Colors.white70), onPressed: () {}),
                IconButton(icon: const Icon(Icons.settings, color: Colors.white70), onPressed: () {}),
              ],
            ),
          ),
          // بدنه داشبورد
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // نوار بالایی ساعت و برند
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TIBA 2 SPORT",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent, letterSpacing: 2),
                      ),
                      Text(
                        _timeString,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ویجت‌های اصلی
                  Expanded(
                    child: Row(
                      children: [
                        // سرعت‌سنج جی‌پی‌اس
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF161F30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentSpeed.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                                ),
                                const Text("km/h", style: TextStyle(color: Colors.white54, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // موزیک و وضعیت
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161F30),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                  ),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.play_circle_fill, size: 48, color: Colors.amber),
                                        SizedBox(width: 12),
                                        Text("پخش موزیک", style: TextStyle(fontSize: 18, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161F30),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text("ناوبری و مسیریاب آنلاین", style: TextStyle(color: Colors.white70)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
