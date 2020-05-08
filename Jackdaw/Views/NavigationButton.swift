//
//  NavigationButton.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-08.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

typealias Destination<V> = Group<V> where V:View
typealias Label<V> = Group<V> where V:View

struct NavigationButton<V1, V2>: View where V1: View, V2: View {
    @State private var isActive = false
    @State private var n = 0
    private var action: ()->Void
        
    let destination: Group<V1>
    let label: Group<V2>

    init(action: @escaping () -> Void, @ViewBuilder _ content: @escaping () -> TupleView<(Destination<V1>, Label<V2>)>) {
        self.action = action
        let (destination, label) = content().value
        self.destination = destination
        self.label = label
    }
    
    init(@ViewBuilder _ content: @escaping () -> TupleView<(Destination<V1>, Label<V2>)>) {
        self.action = {}
        let (destination, label) = content().value
        self.destination = destination
        self.label = label
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
    @State var clickCounter = 0
    
    static var previews: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationButton(action: {
                    print("clicked the pencil button")
                }) {
                    Destination {
                        Text("WRITE ON DUDE!!")
                    }
                    Label {
                        Image(systemName: "pencil.circle")
                            .resizable()
                            .frame(width: 64, height: 64)
                    }
                }
                Spacer()
                NavigationButton {
                    Destination {
                        HStack{
                            Image(systemName: "trash.fill")
                            Text("WELCOME HOME")
                        }
                    }
                    Label {
                        Image(systemName: "trash.circle")
                            .resizable()
                            .frame(width: 64, height: 64)
                    }
                }
                Spacer()
            }
        }
    }
}
