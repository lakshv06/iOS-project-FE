import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignedIn: Bool = false
    @State private var isLoading: Bool = false
    @State private var signInError: String? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Success"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // Handle OK action, e.g., navigate to the next screen
                    isSignedIn = true
                }
            )
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
        
        guard let currentLocation = locationManager.location else {
            signInError = "Location not available"
            isLoading = false
            return
        }

        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        
        sendToBackend(email: email, password: password, deviceName: deviceName, deviceModel: deviceModel, deviceIdentifier: deviceIdentifier, latitude: latitude, longitude: longitude)
    }

    // Backend data
    func sendToBackend(email: String, password: String, deviceName: String, deviceModel: String, deviceIdentifier: String, latitude: Double, longitude: Double) {
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
            "device_identifier": deviceIdentifier,
            "latitude": latitude,
            "longitude": longitude
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
                        alertMessage = "Sign In Successful!"
                        showAlert = true
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
