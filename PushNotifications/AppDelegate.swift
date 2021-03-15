//
//  AppDelegate.swift
//  PushNotifications
//
//  Created by Tristian Azuara on 7/14/20.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForNotifications()
        return true
    }

    // MARK: Remote Notifications

    private func registerForNotifications() {
        let current = UNUserNotificationCenter.current()
        current.delegate = self
        current.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard error == nil else { debugPrint(error); return }
            guard granted else { return }

            DispatchQueue.main.async {
                #if !targetEnvironment(simulator)
                UIApplication.shared.registerForRemoteNotifications()
                #endif
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(#function, error) // error expected in sim.
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint(#function)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint(#function, userInfo)
        completionHandler(.newData)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        debugPrint(#function)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        debugPrint(#function)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo
        debugPrint(userInfo)

        let title = "Notification Received"
        let message = "CustomID: \(userInfo["custom_id"] ?? "")"

        window?.rootViewController?.showAlert(title: title, message: message)
        completionHandler(.list)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}
