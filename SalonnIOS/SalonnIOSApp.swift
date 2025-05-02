//
//  SalonnIOSApp.swift
//  SalonnIOS
//
//  Created by Hunar Adam on 4/28/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀 App Starting...")
        
        // Configure Firebase using the project's existing FirebaseConfigurator
        FirebaseConfigurator.configure()
        
        // Set up messaging delegate
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Handle Firebase Messaging registration
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("📱 Device token registered: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }
    
    // Implement the MessagingDelegate method
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("📩 Firebase registration token: \(String(describing: fcmToken))")
    }
}

@main
struct SalonnIOSApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Create AppViewModel after Firebase is configured
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
