//
//  ContentView.swift
//  SmartShow
//
//  Created by Andre Yost on 4/17/23.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn
import DropDown
import UIKit

struct ContentView: View {
    
    @EnvironmentObject var signupVM: SmartShowViewModel
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //@ObservedObject var appDelegate = AppDelegate()
    @ObservedObject var btleObj = BTLEObject()
    
    @State private var selectedAlbum = "Album"
    @State private var isPickerVisible = false
    @State private var isAlbumDropDownVisible = true
    @State private var isPlay = true
    
    let playStop = ["play", "stop"]
    @State private var selectedPlayStop = "play"
    let speedOptions = ["2", "5", "10"]
    @State private var selectedSpeed = "2"
    let animationOptions = ["in_quad", "out_bounce", "out_quart"]
    @State private var selectedAnimation = "in_quad"
    
    
    var body: some View {
        
        Color.white.ignoresSafeArea()
            .overlay(
                VStack (alignment: .center, spacing: 0) {
                    
                    // LOGO
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(80)
                        .padding(.vertical, UIScreen.main.bounds.size.height / 8)
                    
                    //.disabled(!btleObj.state.isConnected)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        //signup with social title
                        SignUpTitleView(title: "Connect with Google Photo API!")
                            .padding(.vertical)

                    }
                        
                    //initial setup
                    SignUpItemsGroupView()
                    
                    Spacer()
                    
                    Button (action: {appDelegate.getGooglePhotosAPIInfo()}, label: {
                        Text("Get GPhoto API Info")
                            .font(.body)
                            .foregroundColor(Color("hyperLink"))
                    })
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 50) {
                        
                        if isAlbumDropDownVisible {
                            Button("Get Album Options") {
                                isPickerVisible = true
                                isAlbumDropDownVisible = false
                            }
                        }
                                    
                        if isPickerVisible {
                            
                            VStack(alignment: .center, spacing: 10) {
                                
                                Picker(selection: $selectedAlbum, label: Text("")) {
                                    ForEach(MyVariables.albumTitleStringArray, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onReceive([selectedAlbum].publisher.first()) { value in
                                    for i in 0...MyVariables.albumTitleStringArray.count-1 {
                                        if value == MyVariables.albumTitleStringArray[i] {
                                            MyVariables.albumID = MyVariables.albumIDStringArray[i]
                                        }
                                    }
                                    MyVariables.albumSelected = value
                                    print("Selected album: \(MyVariables.albumSelected)")
                                }
                                
                                Picker(selection: $selectedSpeed, label: Text("")) {
                                                    ForEach(speedOptions, id: \.self) {
                                                        Text($0)
                                                    }
                                                }
                                .onReceive([selectedSpeed].publisher.first()) { value in
                                    MyVariables.speedSelected = value
                                    print("Selected speed: \(value)")
                                }
                                
                                Picker(selection: $selectedAnimation, label: Text("")) {
                                                    ForEach(animationOptions, id: \.self) {
                                                        Text($0)
                                                    }
                                                }
                                .onReceive([selectedAnimation].publisher.first()) { value in
                                    MyVariables.animationSelected = value
                                    print("Selected animation: \(value)")
                                }
                                
                            }
                        }
                        
                        VStack(alignment: .center, spacing: 30) {
                            Button (action: {appDelegate.sendBLE()}, label: {
                                Text("Send BLE Info")
                                    .font(.body)
                            })
                            
                            Button (action: {
                                //btleObj.state.charTest = MyVariables.playStopBool
                                btleObj.state.isSetting = true
                                btleObj.state.settingString = "{\"album\": \"\(MyVariables.albumSelected)\", \"album_id\": \"\(MyVariables.albumID)\", \"speed\": \"\(MyVariables.speedSelected)\", \"animation\": \"\(MyVariables.animationSelected)\"}"
                                //btleObj.state.bigString = "12345a 12345a"
                            }, label: {
                                Text("Send SmartShow Settings")
                                    .font(.body)
                            })
                            
                            Button (action: {
                                //btleObj.state.charTest = MyVariables.playStopBool
                                btleObj.state.isCredential = true
                                btleObj.state.credentialString = "{\"token\": \"ya29.a0AWY7CkmlHkpRyyrKNbOnQFZKVr3j7AeV2kihQereXm6KeSx5EXZo4DQhRalIienAgktDyMedSchmBOVultpJNUS8A88ngnPSJWl4qOCSo0sMdw4nXemLHjt2uGMN6hieic4F6Tk1WNgGJVDDMg4vGfXH4mGONHoGaCgYKAa0SARESFQG1tDrpC6KVOoRJEl17IedlqAJREQ0167\", \"refresh_token\": \"1//0dXYtn7zBnI1sCgYIARAAGA0SNwF-L9IrtBp3h5389xtmhm9NC73bzQdKyZSNIwCKywJxa817atenASpLENqF568EOElFNiSfLz8\", \"client_id\": \"1028627541130-cek95c7jpv3p8jnrmr0vjrt7a5i8un0i.apps.googleusercontent.com\", \"client_secret\": \"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\"}" //"{\"token\": \"\(MyVariables.accessToken)\", \"refresh_token\": \"\(MyVariables.refreshToken)\", \"client_id\": \"\(MyVariables.clientID)\", \"client_secret\": \"\(MyVariables.clientSecret)\"}"
                                //btleObj.state.credentialString = "{\"token\": \"\(MyVariables.accessToken)\", \"refresh_token\": \"\(MyVariables.refreshToken)\", \"client_id\": \"\(MyVariables.clientID)\", \"client_secret\": \"\(MyVariables.clientSecret)\"}"
                                //btleObj.state.bigString = "12345a 12345a"
                            }, label: {
                                Text("Send Credential Settings")
                                    .font(.body)
                            })
                            
                            Button (action: {
                                isPlay.toggle()
                                if isPlay {
                                    MyVariables.playStopBool = "stop"
                                } else {
                                    MyVariables.playStopBool = "play"
                                }
                                //btleObj.state.charTest = MyVariables.playStopBool
                                btleObj.state.isState = true
                                btleObj.state.stateString = "{\"state\": \"\(MyVariables.playStopBool)\"}"
                                //btleObj.state.bigString = "12345a 12345a"
                                print(" btleObj.state.stateString: \(btleObj.state.stateString)")
                            }, label: {
                                if isPlay {
                                    Text("PLAY").font(.body)
                                    
                                } else {
                                    Text("STOP").font(.body)
                                }
                                    
                            })
                            
                        }
                        
                    }
                    
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 50) {
                        
                        Button(action: {appDelegate.signOut()}, label: {
                            Text("Sign Out")
                                .font(.body)
                                .foregroundColor(Color("hyperLink"))
                        })
                        
                        Button(action: {appDelegate.refreshToken()}, label: {
                            Text("Refresh Token")
                                .font(.body)
                        })
                    }
                    
                    Spacer()

            
                }// VSTACK
                
            )// WHITE BACKGROUND
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
