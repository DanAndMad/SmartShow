//
//  SmartShowApp.swift
//  SmartShow
//
//  Created by Andre Yost on 4/17/23.
//

import SwiftUI
import GoogleSignIn
import Firebase
import GoogleAPIClientForREST
import GPhotos
import CoreBluetooth
//import GooglePlaces

@main
struct SmartShowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SmartShowViewModel())
                .environmentObject(BTLEObject())
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    @ObservedObject var btleObj = BTLEObject()
    @EnvironmentObject var signupVM: SmartShowViewModel
    var signupVMObj = SmartShowViewModel()
    
//    private func setupPeripheral() {
//        if let lampiPeripheral = lampiPeripheral  {
//            lampiPeripheral.delegate = self
//        }
//    }
//
//    private var devicePeripheral: CBPeripheral?
//
//    var lampiPeripheral: CBPeripheral? {
//        didSet {
//            setupPeripheral()
//        }
//    }
    
    //let viewController = UIApplication.shared.windows.first?.rootViewController as? YourViewController
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                print("signed-out state w/ user: \(user)")
                print("checking sign in: \(GIDSignIn.sharedInstance.hasPreviousSignIn())")
                //print("AUTHENTICATION: \(user?.serverAuthCode)")
            } else {
//                var config = GIDConfiguration()
//                config.printLogs = false
//                GPhotos.initialize(with: config)
                    // Other configs
                print("GIDsignin: signed-in state w/ user: \(user)")
                print("checking sign in: \(GIDSignIn.sharedInstance.hasPreviousSignIn())")
                //print("AUTHENTICATION: \(user.serverAuthCode)")
            }
        }
        return true
    }
    
    func application(_ app: UIApplication,open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]
                     = [:]) -> Bool {
        //let gphotosHandled = GPhotos.continueAuthorizationFlow(with: url)
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func handleSignInButton() {
        GIDSignIn.sharedInstance.signIn(withPresenting: ApplicationUtility.rootViewController) { signInResult, error in
            guard let result = signInResult else {
                // Inspect error
                return
            }
            // If sign in succeeded, display the app's main content View.
            print("handlesigninbutton: signed-in state with user: \(GIDSignIn.sharedInstance.currentUser)")
        }
    }
    
    func getGooglePhotosAPIInfo() {
        
        let params = ["pageSize":"4", "access_token":MyVariables.accessToken] as Dictionary<String, String>
        let header = ["Authorization":"Bearer \(MyVariables.accessToken)"]
        var request = URLRequest(url: URL(string: "https://photoslibrary.googleapis.com/v1/albums")!)
        
        request.setValue( "Bearer \(MyVariables.accessToken)", forHTTPHeaderField: "Authorization") //from Bearer to Basic
        print("request: \(request)")
        request.httpMethod = "GET"
        
//        request.allHTTPHeaderFields = [
//            "x-goog-api-key": MyVariables.accessToken
//        ]
        //request.addValue(MyVariables.accessToken, forHTTPHeaderField: "Authorization")
        
        //request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        //print("session: \(session) \n \n")
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            //print("task: \(task)")
            print("\n \n API response: \n \(response!) \n \n") //removed !
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject> //got rid of data's !
 
                if let albums = json["albums"] as? [[String: Any]] {
                    for album in albums {
                        
                        if let albumTitleString = album["title"]! as? String {
                            print("albumTitleString: \(albumTitleString)")
                            MyVariables.albumTitleStringArray.append(albumTitleString)
                        }
                        
                        if let albumIDString = album["id"]! as? String {
                            print("albumIDString: \(albumIDString)")
                            MyVariables.albumIDStringArray.append(albumIDString)
                        }
                        
                    }
                }
                
                print("\n \n ALBUM TITLES BELOW")
                print(MyVariables.albumTitleStringArray)
                print("\n \n ALBUM IDS BELOW")
                print(MyVariables.albumIDStringArray)
                
                print("json output of api: \n \(json)")
                //print("test stuff: \(json['albums'][0])")
                
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    
    func signOut() {
        print("User \(GIDSignIn.sharedInstance.currentUser) signed out!")
        GIDSignIn.sharedInstance.signOut()
        print("checking sign in: \(GIDSignIn.sharedInstance.hasPreviousSignIn())")
    }
    
    func sendBLE() {
        print("------------------\nSEND BLE MESSAGE \n accToken: \(MyVariables.accessToken) \n refreshToken: \(MyVariables.refreshToken) \n scope: \(MyVariables.scope) \n clientID: \(MyVariables.clientID) \n clientSecret: \(MyVariables.clientSecret) \n selected album: \(MyVariables.albumSelected) \n albumID: \(MyVariables.albumID) \n selected speed: \(MyVariables.speedSelected) \n selected animation: \(MyVariables.animationSelected) \n selected play/stop: \(MyVariables.playStopBool) \n ------------------")
//        let scopeUnwr = MyVariables.scope!
//        print("unwrapped scope \(scopeUnwr)")
        //btleObj.writeState()
    }
    
    func testBLE() {
        let btleObject = BTLEObject()
        autoreleasepool {
            //btleObject.writeState()
            //btleObject.writeOutgoingValue(data: "state: stop")
        }
        print("should have sent BLE Update")
    }
    
    func refreshToken() {
        if let currentUser = GIDSignIn.sharedInstance.currentUser {
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
        }
    }
    
    
    
    //let fields: GMSPlaceField = try! GMSPlaceField(rawValue: UInt64(GMSPlaceField.photos.rawValue))
    //let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(GMSPlaceField.photos.rawValue))
}



    //func handleSignInButton() {
    //    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
    //    { signInResult, error in guard let result = signInResult else {
    //        // Inspect error
    //        return
    //        }
    //      // If sign in succeeded, display the app's main content View.
    //    }
    //}


//    func handleSignInButton() {
//      GIDSignIn.sharedInstance.signIn(
//        withPresenting: rootViewController!) { signInResult, error in
//          guard let result = signInResult else {
//            // Inspect error
//            return
//          }
//          // If sign in succeeded, display the app's main content View.
//        }
//
//    }

    


//import SwiftUI
//import GoogleSignIn
//
//var rootViewController: UIViewController?
//
//@main
//struct SmartShowApp: App {s
//    var body: some Scene {
//      WindowGroup {
//        ContentView()
//          // ...
//          .onAppear {
//            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//              // Check if `user` exists; otherwise, do something with `error`
//            }
//          }
//      }
//    }
//}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//
//        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//          if error != nil || user == nil {
//            // Show the app's signed-out state.
//          } else {
//            // Show the app's signed-in state.
//          }
//        }
//        return true
//    }
//
//    func application(_ app: UIApplication,open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]
//        = [:]) -> Bool {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
//
//
//
//
//    //func handleSignInButton() {
//    //    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
//    //    { signInResult, error in guard let result = signInResult else {
//    //        // Inspect error
//    //        return
//    //        }
//    //      // If sign in succeeded, display the app's main content View.
//    //    }
//    //}
//
//
////    func handleSignInButton() {
////      GIDSignIn.sharedInstance.signIn(
////        withPresenting: rootViewController!) { signInResult, error in
////          guard let result = signInResult else {
////            // Inspect error
////            return
////          }
////          // If sign in succeeded, display the app's main content View.
////        }
////
////    }
//
//
//}


//let album = json["album"]
//print("albumTEST: \(album)")
//                if let album = json["album"] as? [String] {
//                    print("titles: \(album)")
//                }




//MyVariables.albumTitleStringArray.append(album["title"]!)
