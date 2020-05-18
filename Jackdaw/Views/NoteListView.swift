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
        SearchList()
        .navigationBarTitle(Text("Jackdaw"), displayMode: .inline)
        .navigationBarItems(trailing: NewNoteButton()
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
                    .foregroundColor(Typography().styleColor)
                    // padding to make the touch target bigger
                    .padding(.vertical, 36)
                    .padding(.leading, 48)
                    .padding(.trailing, 2)
            }
        }
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
