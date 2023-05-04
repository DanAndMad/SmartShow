//
//  Application.swift
//  SmartShow
//
//  Created by Andre Yost on 4/18/23.
//

import SwiftUI

final class ApplicationUtility {
    
    static var rootViewController: UIViewController {
        
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
