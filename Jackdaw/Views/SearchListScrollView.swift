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
                    .offset(y: -self.searchHeight + (isSearchBarShown ? self.searchHeight : 0.0))
            }
        }
        .background(FixedView())
        .onPreferenceChange(KeyTypes.PrefKey.self) { values in
            if !self.isSearchBarShown {
                self.showSearchBarLogic(values: values)
            }
        }
        .onAppear(perform: {
            self.searchString = ""
            self.isSearchBarShown = false
        })
    }
    
    func showSearchBarLogic(values: [KeyTypes.PrefData]) {
        DispatchQueue.main.async {
            
            // Calculate scroll offset
            let movingBounds = values.first { $0.viewType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.viewType == .fixedView }?.bounds ?? .zero
            let scrollOffset = movingBounds.minY - fixedBounds.minY
            
            if self.previousScrollOffset > self.searchHeight && scrollOffset <= self.searchHeight {
                self.isSearchBarShown = true
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
