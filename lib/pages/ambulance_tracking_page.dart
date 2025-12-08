// lib/pages/ambulance_tracking_page.dart
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

  BitmapDescriptor? _ambulanceIcon;

  final List<LatLng> _ambulancePath = [
    const LatLng(43.2143445, 76.8977278),
    const LatLng(43.2159337, 76.8976406),
    const LatLng(43.2177159, 76.8973315),
    const LatLng(43.2177858, 76.8988852),
    const LatLng(43.2179150, 76.9012465),
    const LatLng(43.2190546, 76.9020160),
    const LatLng(43.2204230, 76.9047133),
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

  Future<void> _loadCustomIcon() async {
    final ByteData data = await rootBundle.load('assets/ambulance_v3.png');
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 120,
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

    _ambulancePath[_ambulancePath.length - 1] = _userLocation!;

    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('user'),
        position: _userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Мен осындамын"),
      ));

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
      setState(() => _remainingSeconds -= 49);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Жаңа шақыру",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red, Colors.redAccent]),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Карта
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(43.2389, 76.8897), zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            onMapCreated: (c) => _mapController = c,
          ),

          // КРАСИВАЯ НИЖНЯЯ ПАНЕЛЬ — ТОЧНО КАК НА СКРИНШОТЕ
                    // НИЖНЯЯ ПАНЕЛЬ — ТОЧНО КАК НА ПОСЛЕДНЕМ СКРИНШОТЕ (меньше и аккуратнее)
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Мини-иконка скорой (меньше и аккуратнее)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/ambulance_v3.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Текст: Бригада №17 + Жолда
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Бригада №17",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Жолда",
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // МАЛЕНЬКИЙ КРАСНЫЙ ОВАЛЬНЫЙ ТАЙМЕР — КАК НАСТОЯЩИЙ КЛОН СКРИНШОТА!
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _remainingSeconds > 0
                          ? "${(_remainingSeconds ~/ 60).toString().padLeft(2,'0')}:${(_remainingSeconds %60).toString().padLeft(2,'0')}"
                          : "00:00",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
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