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
    let styleUIColor = UIColor.init(red: 0.0, green: 0.1, blue: 0.5, alpha: 1.0)
    let bodyUIFont = UIFont.init(name: "AvenirNext-Regular", size: 14.0)!
    let titleUIFont = UIFont(descriptor: UIFont.init(name: "AvenirNext-DemiBold", size: 16.0)!.fontDescriptor.addingAttributes([
        UIFontDescriptor.AttributeName.featureSettings: [
            [
                UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kLowerCaseSmallCapsSelector
            ]
        ]
    ]), size: 16.0)

    func previewStringFrom(string: String) -> NSAttributedString {
        
        if string.count < 1 { return NSAttributedString(string: "") }

        guard let index = string.firstIndex(of: "\n") else {
            return NSAttributedString(string: string,
                                      attributes: [NSAttributedString.Key.font : titleUIFont])
        }

        let title = String(string[..<index])
        let body = String(string[index...])

        let titleBody = NSMutableAttributedString(string: title + body, attributes: [NSAttributedString.Key.font: self.bodyUIFont])
        titleBody.addAttribute(NSAttributedString.Key.font, value: titleUIFont, range: NSRange(location: 0, length: title.count))
        
        return titleBody
    }
    
    func attributedStringFrom(string: String) -> NSAttributedString {
        if string.count < 1 { return NSAttributedString(string: "") }
        
        guard let index = string.firstIndex(of: "\n") else {
            return NSAttributedString(string: string,//.lowercased(with: .current),
                                      attributes: [NSAttributedString.Key.font : titleUIFont])
        }
        
        let title = String(string[..<index])//.lowercased(with: .current)
        let body = String(string[index...])
        
        let lineSpacing = NSMutableParagraphStyle()
        lineSpacing.paragraphSpacing = 4
        let bodyAttributes = [NSAttributedString.Key.font: bodyUIFont,
                              NSAttributedString.Key.paragraphStyle: lineSpacing]
        
        let titleBody = NSMutableAttributedString(string: title + body, attributes: bodyAttributes)
        titleBody.addAttribute(NSAttributedString.Key.font, value: titleUIFont, range: NSRange(location: 0, length: title.count))
        
        return titleBody
    }
}

// MARK: - preview

struct PreviewLabel: UIViewRepresentable {
    let text: String
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.preferredMaxLayoutWidth = 1.0
        label.numberOfLines = 20
        label.attributedText = Typography().attributedStringFrom(string: self.text)
        label.sizeToFit()
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        
    }
}

struct TypographyPreview: PreviewProvider {
    static var previews: some View {

        PreviewLabel(text: "Months before I played Dark Souls I came across a long list of the things players should finish up at the end of their first playthrough.\nFight optional bosses, farm humanity, collect and upgrade weapons, kindle bonfires. Trade for useful items, level up covenants. And last of all, quite simply: kill everyone.")
            .padding()
            .previewLayout(.fixed(width: 350, height: 200))

    }
}
