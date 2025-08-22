import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var methodChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        let flutterViewController = window?.rootViewController as! FlutterViewController

        methodChannel = FlutterMethodChannel(
            name: "photos_method_channel",
            binaryMessenger: flutterViewController.engine.binaryMessenger)

        methodChannel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "generate_thumbnail":
                if let arguments = call.arguments as? [String: Any] {
                    let filePath = arguments["file_path"] as! String
                    let thumbnailPath = arguments["thumbnail_path"] as! String
                    generateThumbnail(filePath: filePath, thumbnailPath: thumbnailPath)
                }
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
