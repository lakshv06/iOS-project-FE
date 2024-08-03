//
//  NotificationUtility.swift
//  iOS-project-FE
//
//  Created by Lakshya Verma on 04/08/24.
//

import Foundation
import UserNotifications
import UIKit

class NotificationUtility {

    static func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }

    static func scheduleLocalNotification(with message: String) {
           // Check if the app is in the background
//           if UIApplication.shared.applicationState == .background
        
               let content = UNMutableNotificationContent()
               content.title = "New Message"
               content.body = message
               content.sound = UNNotificationSound.default
               content.categoryIdentifier = "MESSAGE_CATEGORY"
               // Adding custom data to userInfo
               content.userInfo = ["message": message]
               // Create a trigger to fire immediately
               let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

               // Create the request
               let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

               // Schedule the request with the system
               UNUserNotificationCenter.current().add(request) { error in
                   if let error = error {
                       print("Error scheduling notification: \(error)")
                   } else {
                       print("Notification scheduled successfully")
                   }
               }
           
       }
   }
