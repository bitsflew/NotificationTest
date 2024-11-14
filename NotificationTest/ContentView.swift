//
//  ContentView.swift
//  NotificationTest
//
//  Created by Henk on 21/10/2024.
//

import Firebase
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            PushNotifiactionToggle()
            // PushNotifiactionToggle(statusProvider: NotificationStatus.test(status: .denied))
        }
    }
}

#Preview {
    ContentView()
}

struct NotificationStatus {
    typealias Completion = (UNAuthorizationStatus) -> Void
    typealias Provider = (@escaping NotificationStatus.Completion) -> Void

    static func get(_ completion: @escaping Completion) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    static func test(status: UNAuthorizationStatus) -> Provider {
        { completion in
            completion(status)
        }
    }
}

struct PushNotifiactionToggle: View {
    private let statusProvider: NotificationStatus.Provider
    @State private var isOn = false
    @State private var isProgrammaticChange = false
    @State var authorizationStatus: UNAuthorizationStatus?

    init(_ statusProvider: @escaping (@escaping NotificationStatus.Completion) -> Void = NotificationStatus.get) {
        self.statusProvider = statusProvider
    }

    private func openAppSettings() {
        if let appSettings = URL(string: UIApplication.openNotificationSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }

    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    private func updateAuthorizationStatus() {
        statusProvider { authorizationStatus in
            self.authorizationStatus = authorizationStatus
            isProgrammaticChange = true
            isOn = authorizationStatus == .authorized
            isProgrammaticChange = false
        }

        /*
         UNUserNotificationCenter.current().getNotificationSettings { settings in
             DispatchQueue.main.async {
                 authorizationStatus = settings.authorizationStatus
                 isProgrammaticChange = true
                 isOn = authorizationStatus == .authorized
                 isProgrammaticChange = false
             }
         }
         */
    }

    var body: some View {
        Toggle("Toggle Label", isOn: Binding(
            get: { isOn },
            set: { newValue in
                if !isProgrammaticChange {
                    if newValue, authorizationStatus == .notDetermined {
                        requestPermission()
                    } else {
                        openAppSettings()
                    }
                }
                isOn = newValue
            }
        ))
        .disabled(authorizationStatus == nil)
        .onAppear {
            updateAuthorizationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            updateAuthorizationStatus()
        }
    }
}
