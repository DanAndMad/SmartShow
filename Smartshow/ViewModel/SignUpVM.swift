//
//  LoginVM.swift
//  SmartShow
//
//  Created by Andre Yost on 4/18/23.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleAPIClientForREST
import Foundation

class SmartShowViewModel: NSObject, ObservableObject, UIApplicationDelegate  {
    
    @Published var isLogin: Bool = false
    
    let dateFormatter = DateFormatter()
    
//    override init() {
//        super.init()
//    }
    
    
    func signUpWithGoogle() {
        
        let currentUserForScope = GIDSignIn.sharedInstance.currentUser

        
        // get app client id
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        MyVariables.clientID = clientID
        print("clientID: \(clientID)")

        // get configuration
        let config = GIDConfiguration(clientID: clientID)
        
        print("config: \(config)")

        GIDSignIn.sharedInstance.configuration = config
        
        // sign in
        GIDSignIn.sharedInstance.signIn(withPresenting: ApplicationUtility.rootViewController) {
            //print("AUTHENTICATION: \(user.serverAuthCode)")
            
            //signInResult, err in
            [self] user, err in
            //print("AUTHENTICATION: \(user?.serverAuthCode)")
            
            if let error = err {
                print(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.user
                //let authentication = user?.serverAuthCode
                    
                    //let idToken = authentication.idToken
                    
                    
            else { return }
            print(GIDSignIn.sharedInstance.currentUser)
            //print("AUTHENTICATION: \(user?.serverAuthCode)")
            
            if let currentUser = GIDSignIn.sharedInstance.currentUser {
                let photoScope = "https://www.googleapis.com/auth/photoslibrary.readonly"
                let grantedScopes = currentUser.grantedScopes
                //print("grantedScopes1: \(grantedScopes)")
                if grantedScopes == nil || !grantedScopes!.contains(photoScope) {

                    let additionalScopes = ["https://www.googleapis.com/auth/photoslibrary.readonly"]

                    currentUser.addScopes(additionalScopes, presenting: ApplicationUtility.rootViewController) { signInResult, error in
                        guard error == nil else { return }
                        guard let signInResult = signInResult else { return }
                        MyVariables.scope = currentUser.grantedScopes
                        print("grantedScope: \(currentUser.grantedScopes)")
                        print("checking sign in: \(GIDSignIn.sharedInstance.hasPreviousSignIn())")
                        //print("AUTHENTICATION: \(user?.serverAuthCode)")
                        // Check if the user granted access to the scopes you requested.
                    }

                    currentUser.refreshTokensIfNeeded { user, error in
                        guard error == nil else { return }
                        guard let user = user else { return }

                        // Get the access token to attach it to a REST or gRPC request.
                        let accessToken = user.accessToken.tokenString
                        MyVariables.accessToken = accessToken
                        let tokenExpiration = user.accessToken.expirationDate
                        //MyVariables.tokenExpiration = dateFormatter.string(from:tokenExpiration)
                        let idToken = user.idToken?.tokenString
                        MyVariables.idToken = idToken ?? "no id token"
                        let refreshToken = user.refreshToken.tokenString
                        MyVariables.refreshToken = refreshToken
                        let scope = user.grantedScopes
                        MyVariables.scope = scope
                        let accessTokenType = user.accessToken.accessibilityContainerType
                        //MyVariables.accessTokenType = accessTokenType
                        let refreshTokenType = user.refreshToken.accessibilityContainerType
                        //MyVariables.refreshTokenType = refreshTokenType
                        print("accessToken: \(accessToken)")
                        print("tokenExpiration: \(tokenExpiration)")
                        print("idToken: \(idToken)")
                        print("refreshToken: \(refreshToken)")
                        print("scope: \(scope)")
                        print("accessTokenType: \(accessTokenType)")
                        print("refreshTokenType: \(refreshTokenType)")
                        
                        // Or, get an object that conforms to GTMFetcherAuthorizationProtocol for
                        // use with GTMAppAuth and the Google APIs client library.
                        let authorizer = user.fetcherAuthorizer
                        print("authorizer: \(authorizer)")
                        
                        
                    }
                    //print("grantedScopes: \(currentUser.grantedScopes)")
                }
                
                //print("driveScope: \(photoScope)")
            }
        }
        
    }
    
    
}




//        currentUserForScope?.addScopes(["https://www.googleapis.com/auth/photoslibrary.readonly"], presenting: ApplicationUtility.rootViewController) { signInResult, error in
//            guard error == nil else { return }
//            guard let signInResult = signInResult else { return }
//            MyVariables.scope = currentUserForScope?.grantedScopes
//            print("FIRSTgrantedScope: \(currentUserForScope?.grantedScopes)")
//            print("FIRSTchecking sign in: \(GIDSignIn.sharedInstance.hasPreviousSignIn())")
//            //print("AUTHENTICATION: \(user?.serverAuthCode)")
//            // Check if the user granted access to the scopes you requested.
//        }





//---------------------------------
//user.addScopes(T##scopes: [String]##[String], presenting: <#T##UIViewController#>)
//                    user.addScopes([photoScope], presenting: ApplicationUtility.rootViewController) { signInResult, error in
//                        guard error == nil else { return }
//                        guard let signInResult = signInResult else { return }
//
//                        // Check if the user granted access to the scopes you requested.
//                        //print("granted scopes: \()")
//                    }


//            currentUser.addScopes(["https://www.googleapis.com/auth/photoslibrary.readonly"], presenting: ApplicationUtility.rootViewController)
//        }
//        if let currentUser = GIDSignIn.sharedInstance.currentUser {
//            let additionalScopes = ["https://www.googleapis.com/auth/photoslibrary.readonly"]
//            let grantedScopes = currentUser.grantedScopes
//            currentUser.addScopes(additionalScopes, presenting: ApplicationUtility.rootViewController) { signInResult, error in
//                guard error == nil else { return }
//                guard let signInResult = signInResult else { return }
//                print("grantedScope: \(currentUser.grantedScopes)")
//                print("checking sign in: \(GIDSignIn.sharedInstance.hasPreviousSignIn())")
//                //print("AUTHENTICATION: \(currentUser.serverAuthCode)")
//                // Check if the user granted access to the scopes you requested.
//            }
//        }
