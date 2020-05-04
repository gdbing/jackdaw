//
//  NoteDetailView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-04-30.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI
import UIKit

fileprivate var savedRecently: Bool = false

struct NoteDetailView: View {
    var note: Note?
    
    var body: some View {
        NoteTextFieldView(note: note)
            .padding()
    }
}

struct NoteTextFieldView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var managedObjectContext
    var note: Note?
    
    func makeUIView(context: UIViewRepresentableContext<NoteTextFieldView>) -> UITextView{
        let view = UITextView()
        let text = self.note?.text ?? ""
        view.attributedText = self.attributedStringFrom(string: text)
//        view.textColor = .black
//        view.font = .systemFont(ofSize: 16)
        view.isEditable = true
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<NoteTextFieldView>) {
    }

    // MARK: - Coordinator
    
    func makeCoordinator() -> NoteTextFieldView.Coordinator {
        return NoteTextFieldView.Coordinator(parent: self)
    }
    
    class Coordinator : NSObject,UITextViewDelegate {
        var parent: NoteTextFieldView
        
        init(parent: NoteTextFieldView) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if self.parent.note == nil {
                let newNote = Note(context: self.parent.managedObjectContext)
                newNote.text = ""
                newNote.id = UUID()
                newNote.sortDate = Date()
                self.parent.note = newNote
                
                parent.saveNote()
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                print("textViewDidEndEditing deleted empty note")
                self.parent.managedObjectContext.delete(self.parent.note!)
            } else {
                print("textViewDidEndEditing saved: \(String(describing: textView.text))")
                self.parent.saveNote()
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // probably don't need this if we're not just passing the text on somewhere else
            self.parent.note!.text = textView.text
            textView.attributedText = self.parent.attributedStringFrom(string: textView.text)
            
            if savedRecently { return }
            
            savedRecently = true
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {_ in
                self.parent.saveNote()
                print("textViewDidChange saved: \(String(describing: textView.text))")
                savedRecently = false
            }
        }
    }
    
    // MARK: - Save
    
    func saveNote() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        
//        do {
//            try self.managedObjectContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    
    // MARK: - Attributed String Styling
    
    func stringFrom(attributedString: NSAttributedString) -> String {
        return ""
    }
    
    func attributedStringFrom(string: String) -> NSAttributedString {
        if string.count < 1 { return NSAttributedString(string: "") }
        
        // Body Typography
        let bodyFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        let lineSpacing = NSMutableParagraphStyle()
        lineSpacing.paragraphSpacing = 4
        let bodyAttributes = [NSAttributedString.Key.font: bodyFont,
                              NSAttributedString.Key.paragraphStyle: lineSpacing]
        
        // Title Typography
        let systemFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
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
            //            return NSAttributedString(string: string, attributes: [NSAttributedString.Key.font : bodyAttributes])
            return NSAttributedString(string: string.lowercased(with: .current),
                                      attributes: [NSAttributedString.Key.font : titleFont])
        }
        
        let title = String(string[..<index]).lowercased(with: .current)
        let body = String(string[index...])
        
        let titleBody = NSMutableAttributedString(string: title + body, attributes: bodyAttributes)
        titleBody.addAttribute(NSAttributedString.Key.font, value: titleFont, range: NSRange(location: 0, length: title.count))
        
        return titleBody
    }
}

// MARK - Preview

struct TextFieldPreviewView: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: UIViewRepresentableContext<TextFieldPreviewView>) -> UITextView {
        let view = UITextView()
        view.attributedText = self.attributedStringFrom(string: text)
        view.isEditable = true

        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<TextFieldPreviewView>) {
        
    }
    
    func attributedStringFrom(string: String) -> NSAttributedString {
        if string.count < 1 { return NSAttributedString(string: "") }

        // Body Typography
        let bodyFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        let lineSpacing = NSMutableParagraphStyle()
        lineSpacing.paragraphSpacing = 4
        let bodyAttributes = [NSAttributedString.Key.font: bodyFont,
                     NSAttributedString.Key.paragraphStyle: lineSpacing]

        // Title Typography
        let systemFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
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
//            return NSAttributedString(string: string, attributes: [NSAttributedString.Key.font : bodyAttributes])
            return NSAttributedString(string: string.lowercased(with: .current),
                                      attributes: [NSAttributedString.Key.font : titleFont])
        }

        let title = String(string[..<index]).lowercased(with: .current)
        let body = String(string[index...])

        let titleBody = NSMutableAttributedString(string: title + body, attributes: bodyAttributes)
        titleBody.addAttribute(NSAttributedString.Key.font, value: titleFont, range: NSRange(location: 0, length: title.count))

        return titleBody
    }

}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldPreviewView(text: "Jackdaw")
            .padding()
    }
}
