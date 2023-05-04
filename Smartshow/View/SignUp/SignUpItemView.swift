//
//  SignUpItemView.swift
//  SmartShow
//
//  Created by Andre Yost on 4/18/23.
//

import SwiftUI

struct SignUpItemView: View {
    // PROPERTIES
    let backgroundColor: String
    let image: String
    
    // BODY
    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 25, alignment: .center)
        }// ZSTACK
        .frame(width: 85, height: 60, alignment: .center)
        .background(
            Color(backgroundColor)
                .cornerRadius(10)
                .shadow(color:
                        .black.opacity(0.1), radius: 5, x: 0, y: 1)
        )
    }
}

struct SignUpItemView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpItemView(backgroundColor: "googlecolor", image: "google")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
