import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

  private var methodChannel: FlutterMethodChannel?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

   override func applicationDidFinishLaunching(_ notification: Notification) {

          mainFlutterWindow?.toolbar = NSToolbar()
          if #available(macOS 11.0, *) {
              mainFlutterWindow?.toolbarStyle = .unified
          }

          let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController

                  methodChannel = FlutterMethodChannel(name: "photos_method_channel", binaryMessenger: controller.engine.binaryMessenger)

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


                  NotificationCenter.default.addObserver(self, selector: #selector(onEnterFullScreen), name: NSWindow.didEnterFullScreenNotification, object: nil)
                  NotificationCenter.default.addObserver(self, selector: #selector(onExitFullScreen), name: NSWindow.didExitFullScreenNotification, object: nil)
    }

     @objc func onEnterFullScreen(notification: Notification) {
            mainFlutterWindow?.toolbar = nil
            methodChannel?.invokeMethod("on_enter_fullscreen", arguments: nil)
        }

        @objc func onExitFullScreen(notification: Notification) {
            mainFlutterWindow?.toolbar = NSToolbar()
            if #available(macOS 11.0, *) {
                mainFlutterWindow?.toolbarStyle = .unified
            }
           methodChannel?.invokeMethod("on_exit_fullscreen", arguments: nil)
        }
}
