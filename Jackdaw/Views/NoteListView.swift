//
//  NoteListView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-04-30.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

struct NoteListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Note.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Note.sortDate, ascending: false)],
                  predicate: NSPredicate(format: "text != ''"))
    var notes: FetchedResults<Note>
    // consider moving notes into UserData()
    @State var searchText = ""

    var body: some View {
        NavigationView {
            List {
                SearchBar(text: $searchText)
                ForEach(notes.filter({ searchText.isEmpty ? true : $0.text.contains(searchText)})) { note in
                    NavigationLink(destination: NoteView(note: note)) {
                        ListRowView(note: note)
                    }
                }
                .onDelete { (indexSet) in
                    let noteToDelete = self.notes.filter({ self.searchText.isEmpty ? true : $0.text.contains(self.searchText)})[indexSet.first!]
                    UserData().delete(note: noteToDelete)
                }
            }
            .navigationBarTitle(Text("Jackdaw \(notes.count)"), displayMode: .inline)
            .navigationBarItems(leading: ArchiveButton(),
                                trailing: NewNoteButton()
            )
        }
    }
}

struct ArchiveButton: View {
    var body: some View {
        NavigationLink(destination: Text("this is a filler view"),
                       label: { Image(systemName: "archivebox")})
    }
}

struct NewNoteButton: View {
    @State var isActive = false
    @State var note: Note?
    
    var body: some View {
        ZStack {
            if note != nil {
                NavigationLink(destination: NoteView(note: note!), isActive: self.$isActive) { Text("") }
            }
            Button(action: {
                self.note = UserData().newNote()
                self.isActive = true
            }) {
                Image(systemName: "square.and.pencil")
            }
        }
    }
}

struct ListRowView: View {
    @ObservedObject var note: Note
    
    var body: some View {
        HStack() {
//            GeometryReader { geometry in
//                RowLabelView(text: self.note.text, lines: 3, width: geometry.size.width)
//                    .frame(width: geometry.size.width,
//                           height: geometry.size.height,
//                           alignment: .topLeading)
//            }
            RowLabelView(note: self.note, lines: 3, width: 100.0)
            if note.thumbnail != nil {
                Spacer()
                Image(uiImage: note.thumbnail!)
            }
        }

    }
    
    struct RowLabelView: UIViewRepresentable {
        @ObservedObject var note: Note
        let lines: Int
        let width: CGFloat // this is problematic
        
        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()
            label.preferredMaxLayoutWidth = width // This doesn't work as I expected. The width you pass in doesn't match the width the text fits itself to
            label.numberOfLines = self.lines
            label.attributedText = Typography.attributedStringFrom(string: self.note.text)
            return label
        }
        
        func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<ListRowView.RowLabelView>) {
            uiView.attributedText = Typography.attributedStringFrom(string: self.note.text)
        }

    }

}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        UserData().fakePreviewData()
        return NoteListView().environment(\.managedObjectContext, context)
    }
}
