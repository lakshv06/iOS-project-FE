//
//  SceneDelegate.swift
//  iOS-project-FE
//
//  Created by Lakshya Verma on 04/08/24.
//

import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()

        UNUserNotificationCenter.current().delegate = self
        setupLocationManager()
    }
    
    func setupLocationManager() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.startUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            currentLocation = locations.last
        }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Things reaching to did receive notification \(response)")
          handleNotification(response.notification.request.content.userInfo)
          completionHandler()
      }

      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          print("Things reaching to will oresent notification block \(notification)")
          handleNotification(notification.request.content.userInfo)
          completionHandler([.sound, .alert])
      }
    
    private func handleNotification(_ userInfo: [AnyHashable: Any]) {
        print("Handle notification reached with userinfo: \(userInfo)")
        if let message = userInfo["message"] as? String {
            if let topViewController = UIApplication.shared.windows.first?.rootViewController?.getTopViewController() {
                AlertUtility.showDecisionAlert(on: topViewController, with: message) { accepted in
                    guard let currentLocation = self.currentLocation else {
                        print("Location not available")
                        return
                    }
                    let latitude = currentLocation.coordinate.latitude
                    let longitude = currentLocation.coordinate.longitude

                    WebSocketService.shared.sendResponse(accepted ? "accept" : "reject", latitude: latitude, longitude: longitude)
                }
            }
        }
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

extension UIViewController {
    func getTopViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.getTopViewController()
        } else if let navigationController = self as? UINavigationController, let topViewController = navigationController.topViewController {
            return topViewController.getTopViewController()
        } else if let tabBarController = self as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.getTopViewController()
        } else {
            return self
        }
    }
}
