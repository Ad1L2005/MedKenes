// lib/pages/ambulance_tracking_page.dart — С КАСТОМНОЙ ИКОНКОЙ ambulance_v3.png
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AmbulanceTrackingPage extends StatefulWidget {
  const AmbulanceTrackingPage({super.key});
  @override
  State<AmbulanceTrackingPage> createState() => _AmbulanceTrackingPageState();
}

class _AmbulanceTrackingPageState extends State<AmbulanceTrackingPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _userLocation;
  Timer? _timer;
  int _step = 0;
  int _remainingSeconds = 240;
  final FlutterTts _tts = FlutterTts();
  

  BitmapDescriptor? _ambulanceIcon; // ← наша кастомная иконка

  final List<LatLng> _ambulancePath = [
    const LatLng(43.2259501, 76.9056973),
    const LatLng(43.2280338, 76.9055505),
    const LatLng(43.2308719, 76.9051354),
    const LatLng(43.2334788, 76.9047944),
    const LatLng(43.2352080, 76.9086793),
    const LatLng(43.238949, 76.889700),
  ];
  

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _getUserLocationAndStart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ЗАГРУЖАЕМ ТВОЮ КРАСИВУЮ ИКОНКУ СКОРОЙ
  Future<void> _loadCustomIcon() async {
    final ByteData data = await rootBundle.load('assets/ambulance_v3.png');
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 120, // размер иконки на карте
      targetHeight: 350,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ByteData? byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedImageBytes = byteData!.buffer.asUint8List();

    setState(() {
      _ambulanceIcon = BitmapDescriptor.fromBytes(resizedImageBytes);
    });
  }

  Future<void> _getUserLocationAndStart() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _userLocation = const LatLng(43.238949, 76.889700);
    } else {
      try {
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _userLocation = LatLng(pos.latitude, pos.longitude);
      } catch (e) {
        _userLocation = const LatLng(43.238949, 76.889700);
      }
    }

    _ambulancePath.last = _userLocation!;

    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('user'),
        position: _userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Мен осындамын"),
      ));

      // Первая позиция скорой — ждём загрузки иконки
      if (_ambulanceIcon != null) {
        _markers.add(Marker(
          markerId: const MarkerId('ambulance'),
          position: _ambulancePath[0],
          icon: _ambulanceIcon!,
          rotation: 0,
          anchor: const Offset(0.5, 0.5),
          zIndex: 10,
        ));
      }
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 15));
    _startAmbulanceAnimation();
  }

  void _startAmbulanceAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) async {
      if (_step >= _ambulancePath.length - 1) {
        timer.cancel();
        await _tts.speak("Скорая помощь прибыла! Врачи уже поднимаются по лестнице.");
        if (mounted) {
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Скорая помощь прибыла!", style: TextStyle(fontSize: 20, color: Colors.white)),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 8),
            ),
          );
        }
        return;
      }

      _step++;
      final currentPos = _ambulancePath[_step];
      final prevPos = _ambulancePath[_step - 1];
      final rotation = _calculateBearing(prevPos, currentPos);

      // Обновляем только если иконка загружена
      if (_ambulanceIcon != null) {
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == 'ambulance');
          _markers.add(Marker(
            markerId: const MarkerId('ambulance'),
            position: currentPos,
            icon: _ambulanceIcon!,
            rotation: rotation,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: "Жедел жәрдем №17",
              snippet: "Жетеді: ${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
            ),
          ));
        });
      }

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentPos, 16.5));
      setState(() => _remainingSeconds -= 48);
    });
  }

  double _calculateBearing(LatLng from, LatLng to) {
    final double lat1 = from.latitude * math.pi / 180;
    final double lat2 = to.latitude * math.pi / 180;
    final double dLon = (to.longitude - from.longitude) * math.pi / 180;

    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    var bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return "$min:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Жедел жәрдем жолда", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.red, Colors.redAccent])),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(43.2389, 76.8897), zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            onMapCreated: (c) => _mapController = c,
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                        child: Image.asset('assets/ambulance_v3.png', width: 40, height: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Бригада №17 жолда", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text("Жетеді: ${_formatTime(_remainingSeconds)}", style: GoogleFonts.manrope(fontSize: 16, color: Colors.white70)),
                          ],
                        ),
                      ),
                      Text("103", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _step / (_ambulancePath.length - 1).toDouble(),
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation(Colors.red),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
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