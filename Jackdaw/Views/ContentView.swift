//
//  ContentView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-04-30.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: Typography().styleUIColor,
            .font : UIFont.init(name: "AvenirNext-DemiBold", size: 18.0)!
        ]
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            // For some reason, setting the text attributes of UIBarButtonItem.appearance()
            // breaks the back button, so that you have to tap on the "<" of "< All Notes".
            // If you tap on "All Notes", the text disappears and nothing else happens
            // I don't want to work around it, so we just hide the text
            .foregroundColor: UIColor.clear,
            .font: UIFont.init(name: "AvenirNext-Medium", size: 18.0)!
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
        UINavigationBar.appearance().tintColor = Typography().styleUIColor
    }
    var body: some View {
        NavigationView {
            NoteListView()
//                .onTapGesture {
//                    UIApplication.shared.dismissKeyboard()
//            }
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
