//
//  WebSocketService.swift
//  iOS-project-FE
//
//  Created by Lakshya Verma on 04/08/24.
//

import Foundation
import UIKit

class WebSocketService: NSObject, URLSessionWebSocketDelegate {
    static let shared = WebSocketService()

    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false

    var onMessageReceived: ((String) -> Void)?
    
    private override init() {
        super.init()
    }

    func connect(completion: @escaping (Bool) -> Void) {
        guard !isConnected else {
            print("WebSocket is already connected")
            completion(true)
            return
        }
        
        guard let backendHost = ConfigUtil.backendHost else {
               print("Backend host not found")
               return
           }
        
        

        let url = URL(string: "ws://localhost:8000/")!
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()

        listenForMessages()

        // Assume the connection is established after resume for simplicity
        // You may want to implement more robust connection checking
        isConnected = true
        print("WebSocket is attempting to connect...")
        completion(true)
    }

    func registerDevice(email: String, deviceIdentifier: String) {
        guard isConnected else {
            print("WebSocket is not connected")
            return
        }

        let registerMessage = [
            "type": "register",
            "email": email,
            "deviceIdentifier": deviceIdentifier
        ]

        if let data = try? JSONSerialization.data(withJSONObject: registerMessage, options: []) {
            let message = URLSessionWebSocketTask.Message.data(data)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("Error sending registration message: \(error)")
                } else {
                    print("Registration message sent \(registerMessage)")
                }
            }
        }
    }

    func disconnect() {
        guard isConnected else {
            print("WebSocket is already disconnected")
            return
        }

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        print("WebSocket connection is closing...")
    }

    func send(message: String) {
        guard isConnected else {
            print("Cannot send message, WebSocket is not connected")
            return
        }

        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Message sent: \(message)")
            }
        }
    }
    
    func sendResponse(_ response: String, latitude: Double, longitude: Double) {
        guard isConnected else {
            print("WebSocket is not connected")
            return
        }

        let responseMessage = [
            "type": "response",
            "response": [ "response": response,
                          "location": [
                              "latitude": latitude,
                              "longitude": longitude
                          ]]
        ] as [String : Any]

        if let data = try? JSONSerialization.data(withJSONObject: responseMessage, options: []) {
            let message = URLSessionWebSocketTask.Message.data(data)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("Error sending response message: \(error)")
                } else {
                    print("Response message sent: \(responseMessage)")
                }
            }
        }
    }


    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string message: \(text)")
                    self?.handleReceivedMessage(text)
                    self?.onMessageReceived?(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("Received data message: \(text)")
                        self?.handleReceivedMessage(text)
                        self?.onMessageReceived?(text)
                    }
                @unknown default:
                                // Log the unknown message type and its data
                                print("Unknown message type received: \(message)")
                                fatalError("Unknown message type received: \(message)")
                            }
            case .failure(let error):
                print("Error receiving message: \(error)")
            }

            self?.listenForMessages()
        }
    }
    
    func handleReceivedMessage(_ message: String) {
        if message.contains("\"type\":\"dismiss\"") {
            print("Dismiss message received: \(message)")
            AlertUtility.dismissCurrentAlert() // Dismiss the existing alert
        } else {
            print("Regular message received: \(message)")
            // Handle other types of messages as needed
            // You might want to call a delegate or notification here to handle other cases
        }
    }
}
