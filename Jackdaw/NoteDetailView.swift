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
        view.text = self.note?.text ?? ""
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
            if self.parent.note == nil {
                let newNote = Note(context: self.parent.managedObjectContext)
                newNote.text = ""
                newNote.id = UUID()
                self.parent.note = newNote
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
        do {
            try self.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(note: nil)
    }
}
