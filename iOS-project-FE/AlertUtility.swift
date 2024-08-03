//
//  AlertUtility.swift
//  iOS-project-FE
//
//  Created by Lakshya Verma on 04/08/24.
//

import Foundation

import UIKit

class AlertUtility {
    static func showDecisionAlert(on viewController: UIViewController, with message: String, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { _ in
            completion(true)
        }
        let rejectAction = UIAlertAction(title: "Reject", style: .cancel) { _ in
            completion(false)
        }
        alert.addAction(acceptAction)
        alert.addAction(rejectAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}

