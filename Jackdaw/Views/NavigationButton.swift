//
//  NavigationButton.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-08.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

struct NavigationButton<Label, Destination> : View where Label : View, Destination : View {
    let label: Label
    let destination: Destination
    let action: () -> Void
    @State var isActive = false
    
    init(action: @escaping () -> Void, destination: Destination, @ViewBuilder label: () -> Label) {
        self.action = action
        self.destination = destination
        self.label = label()
    }
    
    init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.action = {}
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        return ZStack {
            NavigationLink(destination: self.destination,
                           isActive: self.$isActive) {
                            Text("")
            }
            Button(action: {
                self.action()
                self.isActive = true
            }) {
                self.label
            }
        }
    }
}

struct NavigationButton_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationButton(action: { },
                                 destination: Text("WRITE ON DUDE!!"),
                                 label: { Image(systemName: "pencil.circle")
                                    .resizable()
                                    .frame(width: 64, height: 64)
                })
                
                Spacer()
                NavigationButton(destination: HStack{
                                    Image(systemName: "trash.fill")
                                    Text("WELCOME HOME")
                                    },
                                 label: { Image(systemName: "trash.circle")
                                    .resizable()
                                    .frame(width: 64, height: 64)
                })
                Spacer()
            }
        }
    }
}
