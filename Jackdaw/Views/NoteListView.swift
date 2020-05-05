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
                  sortDescriptors: [NSSortDescriptor(keyPath: \Note.sortDate, ascending: false)])
    var notes: FetchedResults<Note>
    // consider moving notes into UserData()

    var body: some View {
        NavigationView {
            List {
                ForEach(notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        NoteListRowView(note: note)
                    }
                }
                .onDelete { (indexSet) in
                    let noteToDelete = self.notes[indexSet.first!]
                    UserData().delete(note: noteToDelete)
                }
            }
            .navigationBarTitle(Text("Jackdaw"), displayMode: .inline)
            .navigationBarItems(leading: NavigationLink(
                destination: NoteDetailView(note: nil),
                label: { Image(systemName: "archivebox") }
                ), trailing: NavigationLink(
                    destination: NoteDetailView(note: nil),
                    label: { Image(systemName: "square.and.pencil") }
            ))
        }
    }
}

struct NoteListRowView: View {
    @ObservedObject var note: Note
    
    var body: some View {
        HStack {
            Text(note.headline)
                .lineLimit(2)
                .font(Font.system(.headline).smallCaps())
            if note.thumbnail != nil {
                Spacer()
                Image(uiImage: note.thumbnail!)
            }
        }
    }
}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return NoteListView().environment(\.managedObjectContext, context)
    }
}
