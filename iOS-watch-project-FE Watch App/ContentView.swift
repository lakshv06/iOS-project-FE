//
//  ContentView.swift
//  iOS-watch-project-FE Watch App
//
//  Created by Lakshya Verma on 04/08/24.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignedIn: Bool = false
    @State private var isLoading: Bool = false
    @State private var signInError: String? = nil

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 2) {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.top, 0)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(0)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                            .frame(width: geometry.size.width * 0.85)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(0)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                            .frame(width: geometry.size.width * 0.85)
                        
                        Button(action: signIn) {
                            Text(isLoading ? "Signing In..." : "Sign In")
                                .font(.system(size: 16, weight: .bold))
                                .padding(4)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                                .frame(width: geometry.size.width * 0.85)
                        }
                        .padding(.top, 0)
                        .disabled(isLoading)
                        .navigationDestination(isPresented: $isSignedIn) {
                            HomeView() // Navigate to HomeView upon successful sign-in
                        }
                        
                        if let error = signInError {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                    .frame(width: geometry.size.width)
                }
                .padding(.top, 0)
            }
        }
    }

    private func signIn() {
        isLoading = true
        signInError = nil

        let deviceName = WKInterfaceDevice.current().name
        let deviceModel = WKInterfaceDevice.current().model
        let deviceIdentifier = WKInterfaceDevice.current().identifierForVendor?.uuidString
        
        guard let deviceIdentifier = deviceIdentifier else {
            signInError = "Failed to retrieve device identifier"
            isLoading = false
            return
        }
        
        // Send the UUID and email to your backend server
        sendToBackend(email: email, password: password, deviceName: deviceName, deviceModel: deviceModel, deviceIdentifier: deviceIdentifier)
    }

    // Backend data
    func sendToBackend(email: String, password: String, deviceName: String, deviceModel: String, deviceIdentifier: String) {
        guard let url = URL(string: "http://localhost:8000/sign-in") else {
            signInError = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "email": email,
            "password": password,
            "device_name": deviceName,
            "device_model": deviceModel,
            "device_identifier": deviceIdentifier
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch let error {
            signInError = "Error serializing request body: \(error)"
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    signInError = "Error making POST request: \(error)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Handle successful sign-in
                        isSignedIn = true
                    } else {
                        signInError = "Sign In Failed: \(httpResponse.statusCode)"
                    }
                } else {
                    signInError = "Invalid response"
                }
            }
        }

        task.resume()
    }
}

#Preview {
    ContentView()
}
