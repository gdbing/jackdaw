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
    @State var showPhotoPicker: Bool = false
    @State private var image: UIImage?
    
    var body: some View {
        VStack {
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .scaledToFit()
            }
            NoteTextFieldView(note: note, image: $image)
                .padding()
        }
        .sheet(isPresented: $showPhotoPicker,
               onDismiss: updateNoteWithImage) {
            PhotoPickerView(image: self.$image)
        }
        .navigationBarItems(trailing: Button(action: {
            self.showPhotoPicker = true
        }) {
            Image(systemName: "photo")
            }
        )
    }
    func updateNoteWithImage() {
        // TODO
        // check note exists, or create one.
        // note!.image = self.image
        // if we end up saving the image to file system
        // and keeping a reference in coredata
        // then do that here
    }
}

struct NoteTextFieldView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var managedObjectContext
    var note: Note?
    @Binding var image: UIImage?

    func makeUIView(context: UIViewRepresentableContext<NoteTextFieldView>) -> UITextView{
        let view = UITextView()
        let text = self.note?.text ?? ""
        // TODO
        // image = self.note?.image?
        // pass back the image, if one exists...
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
