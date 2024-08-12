//
//  HomePageViewController.swift
//  iOS-project-FE
//
//  Created by Lakshya Verma on 04/08/24.
//

import Foundation

import UIKit

class HomePageViewController: UIViewController {
    
    @IBAction func signOutTapped(_ sender: Any) {
        print("Sign out button clicked is called")

         WebSocketService.shared.disconnect()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let mainPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? ViewController {
                self.navigationController?.pushViewController(mainPageViewController, animated: true)
            } else {
                print("Error: ViewController with identifier 'MainViewController' not found or class mismatch")
            }
        }
    }
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
                                       if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                           // Check the type of message
                                           if let messageType = json["type"] as? String {
                                               switch messageType {
                                               case "dismiss":
                                                   AlertUtility.dismissCurrentAlert() // Dismiss the existing alert
                                               case "notification":
                                                   if let notificationMessage = json["message"] as? String {
                                                       self?.messageLabel.text = notificationMessage
                                                       // Schedule the notification only if it's a new message
                                                       NotificationUtility.scheduleLocalNotification(with: notificationMessage)
                                                   } else {
                                                       self?.messageLabel.text = "Invalid message format"
                                                   }
                                               default:
                                                   self?.messageLabel.text = "Unknown message type"
                                               }
                                           } else {
                                               self?.messageLabel.text = "Invalid message format"
                                           }
                                       }
                                   } catch {
                        print("Error parsing JSON: \(error)")
                        self?.messageLabel.text = "Error parsing message"
                    }
                }
            }
        }

    }
    
//    @IBAction func signOutTapped(_ sender: UIButton) {
//        print("Sign out button clicked is called")
//         // Notify the backend and disconnect WebSocket
//         WebSocketService.shared.disconnect()
//         // Optionally navigate to the login screen or close the current session
//         // self.dismiss(animated: true, completion: nil)
//     }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
