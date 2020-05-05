//
//  ImageView.swift
//  Jackdaw
//
//  Created by Graham Bing on 2020-05-04.
//  Copyright © 2020 Corvus Corax. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    @State var image: UIImage
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: deleteImage) {
                    Image(systemName: "trash")
                    .padding()
                }
            }
            Spacer()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
    func deleteImage() {
        
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(image: UIImage(systemName: "heart.fill")!)
    }
}
