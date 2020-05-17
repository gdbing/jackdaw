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
        var textAttributes: [NSAttributedString.Key:Any]
        let barItemCustomFont = UIFont.init(name: "AvenirNext-Medium", size: 18.0)
        if let customFont = barItemCustomFont {
            textAttributes = [NSAttributedString.Key.foregroundColor: Typography().styleUIColor,
                              NSAttributedString.Key.font: customFont]
        } else {
            textAttributes = [NSAttributedString.Key.foregroundColor: Typography().styleUIColor]
        }
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
