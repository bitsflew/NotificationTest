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
        }
    }
}

#Preview {
    ContentView()
}

struct PushNotifiactionToggle: View {
    @State private var isOn = false
    @State private var isProgrammaticChange = false
    @State var authorizationStatus: UNAuthorizationStatus?

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
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                authorizationStatus = settings.authorizationStatus
                isProgrammaticChange = true
                isOn = authorizationStatus == .authorized
                isProgrammaticChange = false
            }
        }
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
