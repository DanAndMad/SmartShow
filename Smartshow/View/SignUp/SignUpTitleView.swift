//
//  SignUpTitleView.swift
//  SmartShow
//
//  Created by Andre Yost on 4/18/23.
//

import SwiftUI

struct SignUpTitleView: View {
    let title: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(title)
                .font(.body)
                .padding(.horizontal, 10)
                .foregroundColor(Color.black)
        }
    }
}

struct SignUpTitleView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpTitleView(title: "Get Started!")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
