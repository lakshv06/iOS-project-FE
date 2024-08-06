//
//  ConfigUtil.swift
//  iOS-watch-project-FE Watch App
//
//  Created by Lakshya Verma on 05/08/24.
//

import Foundation
struct ConfigUtil {
    private static func getPlistValue(forKey key: String) -> String? {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path) {
            do {
                let plist = try PropertyListSerialization.propertyList(from: xml, format: nil) as? [String: Any]
                return plist?[key] as? String
            } catch {
                print("Error reading plist: \(error)")
            }
        }
        return nil
    }

    static var backendHost: String? {
        return getPlistValue(forKey: "backend_host")
    }
}

