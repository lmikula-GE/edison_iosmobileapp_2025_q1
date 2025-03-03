//
//  ToDoListAppApp.swift
//  ToDoListApp
//
//  Created by Lauren Mikula on 3/1/25.
//

import UserNotifications
import SwiftUI

@main
struct ToDoListAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
        
        // Set the delegate for the notification center
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // Handle incoming notifications when the app is in the foreground
      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          // This will allow the notification to be shown even when the app is in the foreground
          completionHandler([.badge, .sound, .banner])
      }

      func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
          // Handle the notification response (e.g., opening a specific screen based on the notification)
          let notification = response.notification
          let content = notification.request.content
          print("Received notification: \(content.title)")

          // Call the completion handler
          completionHandler()
      }
}
