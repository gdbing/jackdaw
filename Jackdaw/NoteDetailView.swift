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
    @State var note: Note?
    @State private var showPhotoPicker: Bool = false
    @State private var photoPickerImage: UIImage?
    
    var body: some View {
        VStack {
            if self.photoPickerImage != nil {
                Image(uiImage: photoPickerImage!)
                .resizable()
                .scaledToFit()
            } else if note?.imageData != nil {
                Image(uiImage: note!.image!)
                    .resizable()
                    .scaledToFit()
            }
            NoteTextFieldView(note: $note)
                .padding()
        }
        .sheet(isPresented: $showPhotoPicker,
               onDismiss: updateNoteWithImage) {
            PhotoPickerView(image: self.$photoPickerImage)
        }
        .navigationBarItems(trailing: Button(action: {
            self.showPhotoPicker = true
        }) {
            Image(systemName: "photo")
            }
        )
    }
    func updateNoteWithImage() {
        guard let newImage = self.photoPickerImage else {
            return
        }
        self.note = self.note ?? UserData().newNote()
        self.note!.image = newImage
        UserData().save()
    }
}

struct NoteTextFieldView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var note: Note?
//    @Binding var image: UIImage?

    func makeUIView(context: UIViewRepresentableContext<NoteTextFieldView>) -> UITextView{
        let view = UITextView()
        let text = self.note?.text ?? ""
        view.attributedText = self.attributedStringFrom(string: text)
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
                self.parent.note = UserData().newNote()
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                print("textViewDidEndEditing deleted empty note")
                UserData().delete(note: self.parent.note!)
            } else {
                print("textViewDidEndEditing saved: \(String(describing: textView.text))")
                UserData().save()
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // probably don't need this if we're not just passing the text on somewhere else
            self.parent.note!.text = textView.text
            textView.attributedText = self.parent.attributedStringFrom(string: textView.text)
            
            if savedRecently { return }
            
            savedRecently = true
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {_ in
                UserData().save()
                print("textViewDidChange saved: \(String(describing: textView.text))")
                savedRecently = false
            }
        }
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
        TextFieldPreviewView(text: "Jackdaw\nA fine grey and black bird with pale eyes, related to but smaller than the carrion crow.\nThough thievish and mischievous to the farmer, the jackdaw is a curious and intelligent bird. It has been observed using tools for complex problem solving, like its Corvid cousins.\nThe jackdaw collects and decorates its nest with bright objects. Owing to its fondness for picking up coins, Linnaeus gave it the binomial name Corvus monedula, mǒnēdŭla being derived from the Latin stem of \"money\".\nThe collective noun for a group is a \"clattering\" of jackdaws. The jackdaw call is a familiar hard 'tchack' from which it gets its name. They are gregarious and vocal birds and live in small groups with complex social structures. It will commonly nest in chimneys, buildings, rock crevices and tree holes.")
            .padding()
    }
}
