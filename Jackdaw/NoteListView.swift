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
    @FetchRequest(entity: Note.entity(), sortDescriptors: [])
    var notes: FetchedResults<Note>

    var body: some View {
        NavigationView {
            List {
                ForEach(notes) { note in
                    NavigationLink(destination: NoteDetailView(id: note.id, text: note.text)) {
                        NoteListRowView(note: note)
                    }
                }
            }
            .navigationBarTitle(Text("Jackdaw"), displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(
                destination: NoteDetailView(text: ""),
                label: { Image(systemName: "square.and.pencil") }
            ).padding())
        }
    }
}

struct NoteListRowView: View {
    @ObservedObject var note: Note
    
    var body: some View {
        Text(note.text.split(separator: "\n")[0].trimmingCharacters(in: .whitespacesAndNewlines))
            .lineLimit(1)
    }
}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return NoteListView().environment(\.managedObjectContext, context)
    }
}
