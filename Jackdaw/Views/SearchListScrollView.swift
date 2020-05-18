//
//  HiddenTopView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-13.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//
// See also: https://swiftui-lab.com/scrollview-pull-to-refresh/

import SwiftUI

struct SearchListScrollView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Note.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Note.sortDate, ascending: false)],
                  predicate: NSPredicate(format: "text != ''"))
    var notes: FetchedResults<Note>
    
//    @ObservedObject var keyboardResponder = KeyboardResponder()
    @State private var previousScrollOffset: CGFloat = 0
    @State private var isSearchBarShown: Bool = false
    @State private var searchString: String = ""
    private let searchHeight: CGFloat = 48.0
    
    var body: some View {
        
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                List {
                    ZStack {
                        MovingView()
                        SearchBarView(text: self.$searchString)
                    }
                    .frame(height: self.searchHeight - 12)
                    ForEach(self.filteredNotes()) { note in
                        ListRowView(note: note)
                    }
                    .onDelete { (indexSet) in
                        let noteToDelete = self.filteredNotes()[indexSet.first!]
                        UserData().delete(note: noteToDelete)
                    }
                }

                .frame(height: proxy.size.height + (self.isSearchBarShown ? 0.0 : self.searchHeight))
                .offset(y: (self.isSearchBarShown ? 0.0 : -self.searchHeight/2))
                .background(FixedView())
                .onPreferenceChange(KeyTypes.PrefKey.self) { values in
                    self.onScroll(values: values)
                }
            }
        }
        .navigationBarTitle("Jackdaw", displayMode: .inline)
        .onAppear(perform: {
            UITableView.appearance().separatorColor = .clear
            self.searchString = ""
            self.isSearchBarShown = false
        })
    }
    
    func filteredNotes() -> [Note] {
        return notes.filter({ searchString.isEmpty ? true : $0.text.localizedCaseInsensitiveContains(searchString)})
    }
        
    // MARK: - scroll offset searchbar
    
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
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        UserData().fakePreviewData()

        return NavigationView {
            SearchListScrollView().environment(\.managedObjectContext, context)
        }
    }
}
