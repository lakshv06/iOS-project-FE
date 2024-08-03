//
//  HomePageViewController.swift
//  iOS-project-FE
//
//  Created by Lakshya Verma on 04/08/24.
//

import Foundation

import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    var responseData: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Display the data in the UI
               if let data = responseData {
                   print("Received Data in Home Page: \(data)")
               }
        
                if let data = responseData, let message = data["message"] as? String {
                    messageLabel.text = message
                } else {
                    messageLabel.text = "No message available."
                }
        // Set the closure to update the label when a message is received
        WebSocketService.shared.onMessageReceived = {
            [weak self] message in
            DispatchQueue.main.async {
                print("asfjkghasfkhj: \(message)")
                // Parse the JSON message
                if let data = message.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let notificationMessage = json["message"] as? String {
                            self?.messageLabel.text = notificationMessage
                            
                            // Schedule the notification
                            NotificationUtility.scheduleLocalNotification(with: notificationMessage)
                        } else {
                            self?.messageLabel.text = "Invalid message format"
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                        self?.messageLabel.text = "Error parsing message"
                    }
                }
            }
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
