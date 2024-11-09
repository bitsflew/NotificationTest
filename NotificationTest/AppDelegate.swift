import Firebase
import FirebaseMessaging
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
       
        

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

        return true
    }
    
    func renewFCMToken() {
        Messaging.messaging().deleteToken { [self] error in
            if let error = error {
                print("Error deleting FCM token: \(error)")
            } else {
                print("FCM token deleted successfully.")
                //requestNewToken() // Now fetch a new token
            }
        }
    }
    
    func requestNewToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching new FCM token: \(error)")
            } else if let token = token {
                print("New FCM Token: \(token)")
                // Save or send the new token to your server if needed
            }
        }
    }

    // Called when APNs assigns a device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to FCM
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("APNS Token: \(token)")
        
        if false {
            Task {
                print(UIApplication.shared.isRegisteredForRemoteNotifications)
                UIApplication.shared.unregisterForRemoteNotifications()
                print(UIApplication.shared.isRegisteredForRemoteNotifications)
                test()
            }
        }
        

        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNS Failed to register: \(error.localizedDescription)")
    }

    // Called when FCM generates or refreshes the token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        print("FCM Token: \(fcmToken)")

        // Optionally, send the token to your server
        // sendTokenToServer(fcmToken)
    }

    // Handle notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .banner])
    }
}

@main
struct MyApp: App {
    // Bridge AppDelegate into SwiftUI
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
      
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



func test() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .notDetermined:
            print("Notification permission has not been requested yet.")
        case .denied:
            print("Notifications are disabled for this app.")
        case .authorized:
            print("Notifications are enabled for this app.")
        case .provisional:
            print("Provisional notifications are enabled (quiet permissions).")
        case .ephemeral:
            print("Temporary notification permissions are granted for this app.")
        @unknown default:
            print("Unknown notification authorization status.")
        }
    }
}
