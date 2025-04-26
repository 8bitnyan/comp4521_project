import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add Google Maps API Key
    if let path = Bundle.main.path(forResource: "ApiKeys", ofType: "plist"),
       let keys = NSDictionary(contentsOfFile: path),
       let apiKey = keys["GoogleMapsApiKey"] as? String {
        GMSServices.provideAPIKey(apiKey)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
