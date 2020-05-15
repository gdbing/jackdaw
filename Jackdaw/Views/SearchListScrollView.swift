//
//  HiddenTopView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-13.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//
// See also: https://swiftui-lab.com/scrollview-pull-to-refresh/

import SwiftUI

struct SearchListScrollView<Content: View>: View {
    @ObservedObject var keyboardResponder = KeyboardResponder()

    @State private var previousScrollOffset: CGFloat = 0
    @State private var isSearchBarShown: Bool = false
    @Binding var searchString: String
    private let searchHeight: CGFloat
    let content: Content
    
    init(height: CGFloat = 60, searchString: Binding<String>, @ViewBuilder content: () -> Content) {
        self.searchHeight = height
        self._searchString = searchString
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ScrollView {
                    ZStack(alignment: .top) {
                        MovingView()
                        
                        self.content
                            .alignmentGuide(.top, computeValue: { d in
                                self.isSearchBarShown ? -self.searchHeight : 0.0
                            })
                        
                        SearchBarView(text: self.$searchString)
                            .frame(height: self.searchHeight * 0.25)
                            .padding(.vertical, self.searchHeight * 0.375)
                            .offset(y: -self.searchHeight + (self.isSearchBarShown ? self.searchHeight : 0.0))
                    }
                }
/*
    keyboardResponder.currentHeight can be greater than the amount
    of this view which is being obscured

    `self.keyboardResponder.currentHeight - (UIScreen.main.bounds.size.height-proxy.frame(in: .global)`

    accounts for the small gap at the bottom of the screen on OLED iPhones
    which isn't used by this view, but is filled by the keyboard
 */
                .frame(maxHeight: proxy.size.height - max(self.keyboardResponder.currentHeight - (UIScreen.main.bounds.size.height-proxy.frame(in: .global).maxY), 0))
                .background(FixedView())
                .onPreferenceChange(KeyTypes.PrefKey.self) { values in
                        self.onScroll(values: values)
                }
                .onAppear(perform: {
                    self.searchString = ""
                    self.isSearchBarShown = false
                })
                Spacer()
            }
        }
    }
    
    func onScroll(values: [KeyTypes.PrefData]) {
        DispatchQueue.main.async {
            
            // Calculate scroll offset
            let movingBounds = values.first { $0.viewType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.viewType == .fixedView }?.bounds ?? .zero
            let scrollOffset = movingBounds.minY - fixedBounds.minY
            
            if self.previousScrollOffset > self.searchHeight && scrollOffset <= self.searchHeight {
                self.isSearchBarShown = true
            }
            
            if scrollOffset > 0 {
                UIApplication.shared.dismissKeyboard()
            }
            
            self.previousScrollOffset = scrollOffset
        }
    }
    
    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: KeyTypes.PrefKey.self, value: [KeyTypes.PrefData(viewType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: KeyTypes.PrefKey.self, value: [KeyTypes.PrefData(viewType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
}

struct KeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
    }
    
    struct PrefData: Equatable {
        let viewType: ViewType
        let bounds: CGRect
    }
    
    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []
        
        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }
        
        typealias Value = [PrefData]
    }
}

struct SearchListScrollView_Previews: PreviewProvider {
    static var previews: some View {
        SearchListScrollView(height: 70, searchString: .constant("")) {
            Text("yolo")
        }
    }
}
