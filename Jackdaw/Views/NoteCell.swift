//
//  NoteListRow.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-17.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI


struct NoteCell: View {
    @ObservedObject var note: Note
    @State var isActive = false
//    var previewText: String? = nil
    
    var body: some View {
        ZStack {
            NavigationLink(destination: NoteView(note:self.note), isActive: self.$isActive) { Text("") }
                .hidden()
            Button(action: {
                self.isActive = true
            }) {
                RowLabel(note: self.note, lines: 3)
            }
            
        }
        .frame(height: self.heightForString(string: self.note.text))
    }
    
    struct RowLabel: UIViewRepresentable {
        @ObservedObject var note: Note
        let lines: Int
        
        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()
            label.preferredMaxLayoutWidth = 1.0
            label.numberOfLines = self.lines
            label.attributedText = Typography().attributedStringFrom(string: self.note.truncatedText())
            label.sizeToFit()
            return label
        }
        
        func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<NoteCell.RowLabel>) {
            uiView.attributedText = Typography().attributedStringFrom(string: self.note.truncatedText())
        }
    }
    
    func heightForString(string: String) -> CGFloat {
        let maxHeight: CGFloat = 69.0 // DANGER: MAGIC NUMBER
        let width = UIScreen.main.bounds.size.width
        
        let attrString = Typography().attributedStringFrom(string: self.note.text)
        
        let ts = NSTextStorage(attributedString: attrString)
        let size = CGSize(width:width, height:maxHeight)
        
        let tc = NSTextContainer(size: size)
        tc.lineFragmentPadding = 0.0

        let lm = NSLayoutManager()
        lm.addTextContainer(tc)
        
        ts.addLayoutManager(lm)
        lm.glyphRange(forBoundingRect: CGRect(origin: .zero, size: size), in: tc)

        let rect = lm.usedRect(for: tc)

        return rect.integral.size.height
    }
}

struct SearchListRow: View {
    @ObservedObject var note: Note
    let searchString: String
    
    var body: some View {
        // TODO do special highlighting for the searchString
        NoteCell(note: note)
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
        
        let fourLiner = Note(context: context)
        fourLiner.text = "when I was\na young man\nmy father\ntook me to the city"
        
        return Group {
            NoteCell(note: note)
            NoteCell(note: shortNote)
            NoteCell(note: threeLineNote)
            NoteCell(note: twoLiner)
            NoteCell(note: fourLiner)
        }
        .border(Color.blue, width: 1)
        .previewLayout(.fixed(width: 350, height: 80))

    }
}
