//
//  SwitchToLoginView.swift
//  SmartShow
//
//  Created by Andre Yost on 4/18/23.
//

import SwiftUI

struct SwitchToLoginView: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            
            Text("Already onboard?")
                .font(.body)
            
            Button {
                
            } label: {
                Text("Login")
                    .font(.body)
                    .foregroundColor(Color("hyperLink"))
            }
        }
    }
}

struct SwitchToLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchToLoginView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
