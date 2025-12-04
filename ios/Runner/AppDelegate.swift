import Flutter
import UIKit
import GoogleMaps  // ← ДОБАВЬ ЭТО!

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyD0DXN3DIxDA38taJczK19_azyaogucnMI")  // ← ВСТАВЬ КЛЮЧ
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}