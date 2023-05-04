//
//  SignUpItemsGroupView.swift
//  SmartShow
//
//  Created by Andre Yost on 4/18/23.
//

import SwiftUI

struct SignUpItemsGroupView: View {
    @EnvironmentObject var signupVM: SmartShowViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            //GOOGLE
            Button{
                signupVM.signUpWithGoogle()
            } label: {
                SignUpItemView(backgroundColor: "googleColor", image: "google")
            }
            
        }//HSTACK
    }
}

struct SignUpItemsGroupView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpItemsGroupView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
