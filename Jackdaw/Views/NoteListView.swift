//
//  NoteListView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-04-30.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

struct NoteListView: View {

    var body: some View {
        SearchListScrollView()
        .navigationBarTitle(Text("Jackdaw"), displayMode: .inline)
        .navigationBarItems(leading: ArchiveButton(),
                            trailing: NewNoteButton()
        )
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
    @State var isActive = false
    
    var body: some View {
        VStack {
            Button(action: {
                self.isActive = true
            }) {
                HStack() {
                    RowLabelView(note: self.note, lines: 3, width: 100.0)
                    Spacer()
                    if note.thumbnail != nil {
//                        Image(uiImage: note.thumbnail!)
                    }
                }
                .padding(.horizontal)
            }
            NavigationLink(destination: NoteView(note:note), isActive: $isActive) { Text("") }
            Spacer()
        }
        .frame(maxHeight: 65.0)
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

struct ListRowSearchView: View {
    @ObservedObject var note: Note
    private let searchString: String
    
    var body: some View {
        ListRowView(note: note)
    }
}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        UserData().fakePreviewData()
        return NavigationView {
            NoteListView().environment(\.managedObjectContext, context)
        }
    }
}
