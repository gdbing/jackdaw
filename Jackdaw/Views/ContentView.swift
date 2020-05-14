//
//  ContentView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-04-30.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var searchString: String = ""

    var body: some View {
//        NoteListView()
//            .onAppear(perform: {
//                // Don't show the lines between items in list view
        //                UITableView.appearance().separatorStyle = .none
        //
        //            })
        NavigationView {
            SearchListScrollView(searchString: $searchString) {
                NoteListView(filteredBy: $searchString)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        UserData().fakePreviewData()
        
        return ContentView().environment(\.managedObjectContext, context)
    }
}
#endif
