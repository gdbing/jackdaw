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
        NavigationView {
            SearchListScrollView(searchString: $searchString) {
                NoteListView(filteredBy: $searchString)
            }
            .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
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
