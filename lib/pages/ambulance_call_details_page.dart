// lib/pages/ambulance_call_details_page.dart — ПОЛНОСТЬЮ ПРОЗРАЧНО, КАК НА СКРИНШОТЕ!
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AmbulanceCallDetailsPage extends StatelessWidget {
  const AmbulanceCallDetailsPage({super.key});

  final Map<String, dynamic> callData = const {
    "patientName": "Адиль Нургожа",
    "age": "25 жас",
    "phone": "+7 (707) 123-45-67",
    "address": "Төле би 145, кв. 28, 3-подъезд, домофон 28",
    "reason": "Күшті бас ауырып, құсу, естен тану қаупі",
    "location": LatLng(43.238949, 76.889700),
    "eta": "4 минут",
  };

  void _openNavigator() async {
    final lat = callData["location"].latitude;
    final lng = callData["location"].longitude;
    final google = Uri.parse("google.navigation:q=$lat,$lng");
    final yandex = Uri.parse("yandexnavi://build_route_on_map?lat_to=$lat&lon_to=$lng");

    if (await canLaunchUrl(google)) {
      launchUrl(google, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(yandex)) {
      launchUrl(yandex, mode: LaunchMode.externalApplication);
    }
  }

  void _callPatient() => launchUrl(Uri.parse("tel:${callData["phone"]}"));

  @override
  Widget build(BuildContext context) {
    final data = callData;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Жаңа шақыру",
          style: GoogleFonts.inter(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 10)],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFFF6B00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // Карта на весь экран
          GoogleMap(
            initialCameraPosition: CameraPosition(target: data["location"], zoom: 16.5),
            markers: {
              Marker(
                markerId: const MarkerId("patient"),
                position: data["location"],
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // КНОПКИ — ПРЯМО НА КАРТЕ, СВЕРХУ!
          Positioned(
            bottom: bottomSafe + 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Звонок
                FloatingActionButton(
                  heroTag: "call",
                  backgroundColor: Colors.green,
                  elevation: 15,
                  onPressed: _callPatient,
                  child: const Icon(Icons.call, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 16),

                // Навигация — ОГОНЬ!
                Expanded(
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFFF6B00)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(38),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.7),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _openNavigator,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.navigation, size: 38, color: Colors.white),
                          const SizedBox(width: 14),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "НАВИГАЦИЯ",
                                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                "шамамен ${data["eta"]}",
                                style: GoogleFonts.manrope(fontSize: 15, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}