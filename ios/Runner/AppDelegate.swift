import Flutter
import flutter_local_notifications
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let recurringNotfiChannel = FlutterMethodChannel(name: "com.fbdco.moments.diary.mc/recurring_notif",
                                                         binaryMessenger: controller.binaryMessenger)
        
        recurringNotfiChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            // Note: this method is invoked on the UI thread.
            
            switch call.method {
            case "schedule":
                guard let callArgs = call.arguments as? [String: Any] else { break }
                let title = callArgs["title"] as! String
                let body = callArgs["body"] as! String
                let hour = callArgs["hour"] as! Int
                let minute = callArgs["minute"] as! Int
                let id = callArgs["id"] as! Int
                
                self?.scheduleRecurringNotif(
                    result: result,
                    title: title,
                    body: body,
                    hour: hour,
                    minute: minute,
                    id: id
                )
                break
            case "cancel":
                guard let callArgs = call.arguments as? [String: Any] else { break }
                let id = callArgs["id"] as! Int

                self?.cancelRecurringNotif(result: result, id: id)
                break
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(with: registry)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    
    private func scheduleRecurringNotif(
        result: FlutterResult,
        title: String,
        body: String,
        hour:  Int,
        minute: Int,
        id: Int
    
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
           
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)
        
        let uuidString = "recurr_\(id)"
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        Task {
            let notificationCenter = UNUserNotificationCenter.current()
            do {
                try await notificationCenter.add(request)
            } catch {
                // Handle errors that may occur during add.
            }
        }
    }
    
    private func cancelRecurringNotif(
        result: FlutterResult,
        id: Int
    ){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["recurr_\(id)"])
    }
}
