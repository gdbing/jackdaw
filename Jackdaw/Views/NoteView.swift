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
    @State private var showPhotoPicker: Bool = false
    @State private var photoPickerImage: UIImage?
    
    var body: some View {
//        ScrollView {
//            GeometryReader { proxy in
//                VStack {
//                    if self.note.imageData != nil {
//                        NavigationLink(destination: ImageView(image: self.note.image!)) {
//                            Image(uiImage: self.note.image!)
//                                .resizable()
//                                //                            .scaledToFit()
//                                .frame(width:proxy.size.width)
//                        }.buttonStyle(PlainButtonStyle())
//                    }
                    NoteTextFieldView(note: self.note)
                        .padding()
//                }
//                .sheet(isPresented: self.$showPhotoPicker,
//                       onDismiss: self.updateNoteWithImage) {
//                        PhotoPickerView(image: self.$photoPickerImage)
//                }
//                .navigationBarItems(trailing: Button(action: {
//                    self.showPhotoPicker = true
//                }) {
//                    Image(systemName: "photo")
//                    }
//                )
//            }
//        }
    }
    func updateNoteWithImage() {
        guard let newImage = self.photoPickerImage else {
            return
        }
        self.photoPickerImage = nil
        self.note.image = newImage
        UserData().save()
    }
}

struct NoteTextFieldView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var note: Note

    func makeUIView(context: UIViewRepresentableContext<NoteTextFieldView>) -> UITextView{
        let view = UITextView()
        let text = self.note.text
        view.attributedText = Typography.attributedStringFrom(string: text)
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
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                print("textViewDidEndEditing deleted empty note")
                UserData().delete(note: self.parent.note)
            } else {
                print("textViewDidEndEditing saved: \(String(describing: textView.text))")
                UserData().save()
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // probably don't need this if we're not just passing the text on somewhere else
            self.parent.note.text = textView.text
            textView.attributedText = Typography.attributedStringFrom(string: textView.text)
            
            if savedRecently { return }
            
            savedRecently = true
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {_ in
                UserData().save()
                print("textViewDidChange saved: \(textView.text!)\n\(self.parent.note.id!.uuidString)")
                savedRecently = false
            }
        }
    }
}

// MARK - Preview

struct TextFieldPreviewView: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: UIViewRepresentableContext<TextFieldPreviewView>) -> UITextView {
        let view = UITextView()
        view.attributedText = Typography.attributedStringFrom(string: text)
        view.isEditable = true

        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<TextFieldPreviewView>) {
        
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldPreviewView(text: "Jackdaw\nA fine grey and black bird with pale eyes, related to but smaller than the carrion crow.\nThough thievish and mischievous to the farmer, the jackdaw is a curious and intelligent bird. It has been observed using tools for complex problem solving, like its Corvid cousins.\nThe jackdaw collects and decorates its nest with bright objects. Owing to its fondness for picking up coins, Linnaeus gave it the binomial name Corvus monedula, mǒnēdŭla being derived from the Latin stem of \"money\".\nThe collective noun for a group is a \"clattering\" of jackdaws. The jackdaw call is a familiar hard 'tchack' from which it gets its name. They are gregarious and vocal birds and live in small groups with complex social structures. It will commonly nest in chimneys, buildings, rock crevices and tree holes.")
            .padding()
    }
}
