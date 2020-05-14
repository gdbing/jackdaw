//
//  UIApplication+Keyboard.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-14.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import UIKit

extension UIApplication {
    func dismissKeyboard() {
//        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        self.windows.forEach { $0.endEditing(false) } // iPad code to handle multiple windows
    }
}
