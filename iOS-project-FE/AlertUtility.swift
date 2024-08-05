//
//  AlertUtility.swift
//  iOS-project-FE
//
//  Created by Lakshya Verma on 04/08/24.
//
import Foundation
import UIKit

class AlertUtility {
    static var currentAlert: UIAlertController?
    
    static func showDecisionAlert(on viewController: UIViewController, with message: String, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { _ in
            completion(true)
            currentAlert = nil
        }
        let rejectAction = UIAlertAction(title: "Reject", style: .cancel) { _ in
            completion(false)
            currentAlert = nil
        }
        alert.addAction(acceptAction)
        alert.addAction(rejectAction)
        currentAlert = alert
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    static func dismissCurrentAlert() {
        DispatchQueue.main.async {
            currentAlert?.dismiss(animated: true, completion: nil)
            currentAlert = nil
        }
    }
}
