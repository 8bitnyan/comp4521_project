import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // This must be called before any Google Maps widget is used!
    if let path = Bundle.main.path(forResource: "ApiKeys", ofType: "plist") {
    print("ApiKeys.plist found at: \(path)")
    if let keys = NSDictionary(contentsOfFile: path),
       let apiKey = keys["GoogleMapsApiKey"] as? String {
        print("Loaded Google Maps API Key: \(apiKey)")
        GMSServices.provideAPIKey(apiKey)
    } else {
        print("Could not read GoogleMapsApiKey from ApiKeys.plist")
    }
    } else {
        print("ApiKeys.plist not found in bundle")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
