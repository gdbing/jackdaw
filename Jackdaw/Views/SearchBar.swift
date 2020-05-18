//
//  SearchBarView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-09.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search", text: $text)
            .font(Font.custom("AvenirNext-Regular", size: 16.0))
//            .font(Font.)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if self.text != "" {
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                })
            .padding(.horizontal, 10)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SearchBar(text: .constant(""))
            SearchBar(text: .constant("a thousand bees"))
            SearchBar(text: .constant("Jackdaw"))
            Spacer()
        }
    }
}
