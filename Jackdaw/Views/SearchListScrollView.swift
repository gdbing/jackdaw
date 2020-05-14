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
    
    @State private var isSearchShown: Bool = false
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
                    self.isSearchShown ? -self.searchHeight : -1.0
                })
                
                SearchBar(text: self.$searchString)
                    .frame(height: self.searchHeight * 0.25)
                    .padding(.vertical, self.searchHeight * 0.375)
                    .offset(y: -self.searchHeight + (isSearchShown ? self.searchHeight : 0.0))
            }
        }
        .background(FixedView())
        .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
            self.refreshLogic(values: values)
        }
        .onAppear(perform: {
            self.searchString = ""
            self.isSearchShown = false
        })
    }
    
    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            let scrollOffset = movingBounds.minY - fixedBounds.minY
            
            if self.previousScrollOffset > self.searchHeight && scrollOffset <= self.searchHeight {
                self.isSearchShown = true
            }
            
            self.previousScrollOffset = scrollOffset
        }
    }
    
    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
}

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
    }
    
    struct PrefData: Equatable {
        let vType: ViewType
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

//struct SearchListScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchListScrollView(height: 70) {
//            Text("yolo")
//        }
//    }
//}
