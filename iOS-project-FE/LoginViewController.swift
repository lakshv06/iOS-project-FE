//
//  LoginViewController.swift
//  iOS-project-FE
//
//  Created by Lakshya Verma on 04/08/24.
//

import Foundation
import UIKit
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate {

    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        checkLocationAuthorization()

        // Do any additional setup after loading the view.
        // Set up tap gesture recognizer
              let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
              view.addGestureRecognizer(tapGesture)

              // Set text field delegates
              emailTextField.delegate = self
              passwordTextField.delegate = self
    }
    
    @objc func dismissKeyboard() {
          view.endEditing(true)
      }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }

    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        print("Email: \(email)")
        print("Password: \(password)")
        
        showToast(message: "Trying Sign in", duration: 2.0)
            let deviceName = UIDevice.current.name
            let deviceModel = UIDevice.current.model
            let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString
        
            print("Device Name: \(deviceName)")
            print("Device Model: \(deviceModel)")
            print("Device Identifier: \(String(describing: deviceIdentifier))")
        
        // Send the UUID and email to backend server here
        if deviceIdentifier != nil {
                sendToBackend(email: email, password: password, deviceName: deviceName, deviceModel: deviceModel, deviceIdentifier: deviceIdentifier!)
                }
        
    }
    
    func checkLocationAuthorization() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        } else {
            print("Location services not authorized")
        }
    }

    
    // backend data
    func sendToBackend(email: String, password: String, deviceName: String, deviceModel: String, deviceIdentifier: String) {
        
        guard let backendHost = ConfigUtil.backendHost else {
               print("Backend host not found")
               return
           }
        
        guard let url = URL(string: "http://localhost:8000/sign-in") else {
            print("Invalid URL")
            return
        }
        
        guard let currentLocation = self.currentLocation else {
            print("ehehehe Location not available")
            return
        }
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "email": email,
            "password": password,
            "device_name": deviceName,
            "device_model": deviceModel,
            "device_identifier": deviceIdentifier,
            "latitude": latitude,
            "longitude": longitude
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch let error {
            print("Error serializing request body: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making POST request: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Sign in route response status code: \(httpResponse.statusCode)")

                if let data = data {
                    do {
                        if let responseBody = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Response Body: \(responseBody)")

                            DispatchQueue.main.async {
                                if httpResponse.statusCode == 200 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        if let homePageViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                                            homePageViewController.responseData = responseBody // Pass the data
                                            self.navigationController?.pushViewController(homePageViewController, animated: true)
                                        }
                                    }

                                    // Connect the WebSocket and register the device
                                    WebSocketService.shared.connect { isConnected in
                                        if isConnected {
                                            WebSocketService.shared.registerDevice(email: email, deviceIdentifier: deviceIdentifier)
                                        } else {
                                            print("Failed to connect WebSocket")
                                        }
                                    }
                                } else {
                                    self.showToast(message: "Signin failed", duration: 2.0)
                                }
                            }
                        } else if let responseString = String(data: data, encoding: .utf8) {
                            print("Response String: \(responseString)")
                        }
                    } catch let error {
                        print("Error parsing response body: \(error)")
                    }
                }
            }
        }

        task.resume()
    }


    
    // Function to display a toast-like message
    func showToast(message: String, duration: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        // Duration for how long the toast should appear
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
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

extension LoginViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            print("Current location updated: \(location)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
}
