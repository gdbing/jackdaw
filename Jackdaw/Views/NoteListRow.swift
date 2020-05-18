//
//  NoteListRow.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-17.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI


struct NoteListRow: View {
    @ObservedObject var note: Note
    @State var isActive = false
    @State var height: CGFloat = 10.0
    
    var body: some View {
        ZStack {
            Button(action: {
                self.isActive = true
            }) {
//                HStack() {
                    RowLabel(note: self.note, lines: 3, height: $height)
//                    if note.thumbnail != nil {
//                        Spacer()
//                        Image(uiImage: note.thumbnail!)
//                    }
//                }
            }
            NavigationLink(destination: NoteView(note:note), isActive: $isActive) { Text("") }.hidden()
        }
        .frame(maxHeight: height)
    }
    
    struct RowLabel: UIViewRepresentable {
        @ObservedObject var note: Note
        let lines: Int
        @Binding var height: CGFloat
        
        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()
            // preferredMaxLayoutWidth doesn't work as I expected.
            // The width you pass in doesn't match the width the text fits itself to
            // just assigning any value seems to be like toggling a bool switch
            label.preferredMaxLayoutWidth = 1.0
            label.numberOfLines = self.lines
            label.attributedText = Typography.previewStringFrom(string: self.note.text)
            label.sizeToFit()
            DispatchQueue.main.async {
                // TODO are we worried about an infinite resizing loop here?
                self.height = label.frame.size.height
            }
            return label
        }
        
        func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<NoteListRow.RowLabel>) {
            uiView.attributedText = Typography.previewStringFrom(string: self.note.text)
        }
    }
}

struct SearchListRow: View {
    @ObservedObject var note: Note
    let searchString: String
    
    var body: some View {
        // TODO do special highlighting for the searchString
        NoteListRow(note: note)
    }
}


struct NoteListRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let note = Note(context: context)
        note.text = "Jackdaw\nA fine grey and black bird with pale eyes, related to but smaller than the carrion crow.\nThough thievish and mischievous to the farmer, the jackdaw is a curious and intelligent bird. It has been observed using tools for complex problem solving, like its Corvid cousins.\nThe jackdaw collects and decorates its nest with bright objects. Owing to its fondness for picking up coins, Linnaeus gave it the binomial name Corvus monedula, mǒnēdŭla being derived from the Latin stem of \"money\".\nThe collective noun for a group is a \"clattering\" of jackdaws. The jackdaw call is a familiar hard 'tchack' from which it gets its name. They are gregarious and vocal birds and live in small groups with complex social structures. It will commonly nest in chimneys, buildings, rock crevices and tree holes."

        let shortNote = Note(context: context)
        shortNote.text = "so it goes, I suppose"
        
        let threeLineNote = Note(context: context)
        threeLineNote.text = "one\ntwo\nthree"
        let twoLiner = Note(context: context)
        twoLiner.text = "the first line\nthe second line"
        return NavigationView {
            List {
                NoteListRow(note: note)
                NoteListRow(note: shortNote)
                NoteListRow(note: threeLineNote)
                NoteListRow(note: twoLiner)
            }
        }
    }
}
