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

struct NoteView: View {
    @ObservedObject var note: Note
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            GeometryReader { proxy in
                NoteTextFieldView(note: self.note)
                    .padding(.horizontal)
                    .padding(.top)
                Spacer()
            }
        }
    }
}

struct NoteTextFieldView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var note: Note
    @ObservedObject var keyboardResponder = KeyboardResponder()
    @State var view: UITextView = UITextView()

    func makeUIView(context: UIViewRepresentableContext<NoteTextFieldView>) -> UITextView{
//        view = UITextView()
        let text = self.note.text
        
        view.attributedText = Typography().attributedStringFrom(string: text)
        view.isEditable = true
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        view.keyboardDismissMode = .interactive

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
            super.init()
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideShow(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        }
                
        func textViewDidBeginEditing(_ textView: UITextView) {
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" && self.parent.note.image == nil {
                UserData().delete(note: self.parent.note)
            } else {
                UserData().save()
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // probably don't need this if we're not just passing the text on somewhere else
            self.parent.note.text = textView.text
            textView.attributedText = Typography().attributedStringFrom(string: textView.text)
            
            if savedRecently { return }
            
            savedRecently = true
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {_ in
                UserData().save()
                savedRecently = false
            } 
        }
        @objc func keyboardHideShow(sender: NSNotification) {
            self.parent.view.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: self.parent.keyboardResponder.currentHeight, right: 0)
        }

        @objc func keyboardWillHide(sender: NSNotification) {
            self.parent.view.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: self.parent.keyboardResponder.currentHeight + 40, right: 0)
        }
    }
}

// MARK: -

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let note = Note(context: context)
        note.text = "Jackdaw\nA fine grey and black bird with pale eyes, related to but smaller than the carrion crow.\nThough thievish and mischievous to the farmer, the jackdaw is a curious and intelligent bird. It has been observed using tools for complex problem solving, like its Corvid cousins.\nThe jackdaw collects and decorates its nest with bright objects. Owing to its fondness for picking up coins, Linnaeus gave it the binomial name Corvus monedula, mǒnēdŭla being derived from the Latin stem of \"money\".\nThe collective noun for a group is a \"clattering\" of jackdaws. The jackdaw call is a familiar hard 'tchack' from which it gets its name. They are gregarious and vocal birds and live in small groups with complex social structures. It will commonly nest in chimneys, buildings, rock crevices and tree holes."
        return NoteView(note: note)
    }
}
