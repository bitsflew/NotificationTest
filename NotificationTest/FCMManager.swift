import Firebase
import FirebaseMessaging

class FCMManager: NSObject, MessagingDelegate {

    static let shared = FCMManager()
    
    private override init() {
        super.init()
        // Set the messaging delegate to self
        Messaging.messaging().delegate = self
    }

    // Function to get FCM token
    func getFCMToken(completion: @escaping (String?) -> Void) {
        // Check if the token is already available
        if let token = Messaging.messaging().fcmToken {
            completion(token) // Return the token if it already exists
        } else {
            // If not available, fetch the token asynchronously
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM token: \(error.localizedDescription)")
                    completion(nil)
                } else if let token = token {
                    print("FCM Token fetched successfully: \(token)")
                    completion(token) // Return the fetched token
                }
            }
        }
    }
    
    // Handle token updates (optional if you want to react to token changes)
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token updated: \(fcmToken ?? "")")
        // You can store the new token in your server if needed
    }
}

