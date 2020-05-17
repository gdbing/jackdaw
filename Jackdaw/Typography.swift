//
//  Typography.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-05.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

class Typography {
    
    let styleColor = Color.init(red: 0.0, green: 0.1, blue: 0.5)
    
    static func attributedStringFrom(string: String) -> NSAttributedString {
        if string.count < 1 { return NSAttributedString(string: "") }
        
        // Body Typography
        let bodyFont = UIFont.init(name: "AvenirNext-Medium", size: 14.0)!//UIFont.systemFont(ofSize: 14.0, weight: .regular)
        let lineSpacing = NSMutableParagraphStyle()
        lineSpacing.paragraphSpacing = 4
        let bodyAttributes = [NSAttributedString.Key.font: bodyFont,
                              NSAttributedString.Key.paragraphStyle: lineSpacing]
        
        // Title Typography
        let systemFont = UIFont.init(name: "AvenirNext-DemiBold", size: 14.0)!//UIFont.systemFont(ofSize: 14.0, weight: .bold)
        let smallCapsDesc = systemFont.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kLowerCaseSmallCapsSelector
                ]
            ]
        ])
        let titleFont = UIFont(descriptor: smallCapsDesc, size: 16.0)
        
        guard let index = string.firstIndex(of: "\n") else {
            return NSAttributedString(string: string,//.lowercased(with: .current),
                                      attributes: [NSAttributedString.Key.font : titleFont])
        }
        
        let title = String(string[..<index])//.lowercased(with: .current)
        let body = String(string[index...])
        
        let titleBody = NSMutableAttributedString(string: title + body, attributes: bodyAttributes)
        titleBody.addAttribute(NSAttributedString.Key.font, value: titleFont, range: NSRange(location: 0, length: title.count))
        
        return titleBody
    }
}
