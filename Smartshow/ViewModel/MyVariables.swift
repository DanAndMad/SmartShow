//
//  MyVariables.swift
//  SmartShow
//
//  Created by Andre Yost on 5/3/23.
//

import Foundation

struct MyVariables {
    static var clientID = "currently no clientID"
    static var albumID = "currently no albumID"
    static var accessToken = "currently no accessToken"
    static var tokenExpiration = "currently no tokenExpiration"
    static var idToken = "currently no idToken"
    static var refreshToken = "currently no refreshToken"
    static var scope:[String]? = ["currently no scope"]
    static var accessTokenType = "currently no accessTokenType"
    static var refreshTokenType = "currently no refreshTokenType"
    static var albumTitleStringArray = [String]()
    static var albumIDStringArray = [String]()
    static let defaultAlbumTitle = "My Album"
    static var albumSelected = "currently no album selected"
    static var playStopBool = "current no play/stop (T/F) selected"
    static var speedSelected = "currently no speed selected"
    static var animationSelected = "currently no animation selected"
    static var clientSecret = "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"
    
    static func initializeAlbumTitleStringArray() {
            albumTitleStringArray.append(defaultAlbumTitle)
        }
}




//let tokenExpiration = user.accessToken.expirationDate
//let idToken = user.idToken?.tokenString
//let refreshToken = user.refreshToken.tokenString
//let scope = user.grantedScopes
//let accessTokenType = user.accessToken.accessibilityContainerType
//let refreshTokenType = user.refreshToken.accessibilityContainerType
