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
    @State var id: UUID?
    @State var text: String
    
    var body: some View {
        NoteTextFieldView(text: $text)
            .padding()
    }
}

struct NoteTextFieldView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var text : String
    
    func makeUIView(context: UIViewRepresentableContext<NoteTextFieldView>) -> UITextView{
        let view = UITextView()
        view.text = self.text
        view.textColor = .black
        view.font = .systemFont(ofSize: 16)
        view.isEditable = true
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<NoteTextFieldView>) {
    }

    // MARK: Coordinator
    
    func makeCoordinator() -> NoteTextFieldView.Coordinator {
        return NoteTextFieldView.Coordinator(parent: self)
    }
    
    class Coordinator : NSObject,UITextViewDelegate {
        var parent: NoteTextFieldView
        
        init(parent: NoteTextFieldView) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if self.parent.text == ""{
                textView.text = ""
                textView.textColor = .black
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            // TODO delete empty notes
            
            print("textViewDidEndEditing saved: \(String(describing: textView.text))")
            self.parent.saveNote()
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // probably don't need this if we're not just passing the text on somewhere else
            self.parent.text = textView.text

            if savedRecently { return }
            
            savedRecently = true
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {_ in
                self.parent.saveNote()
                print("textViewDidChange saved: \(String(describing: textView.text))")
                savedRecently = false
            }
        }
    }
    
    // MARK: Save
    
    func saveNote() {
        print("saveNote()")
//        let newNote = Note(context: self.managedObjectContext)
//        newNote.id = (self.id != nil) ? self.id! : UUID()
//        newNote.text = self.text
                
//        do {
//            try self.managedObjectContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(text:"This is a note\n\nlook at how good it is.")
    }
}
