//////
//////  SmartShowAlbum.swift
//////  SmartShow
//////
//////  Created by Andre Yost on 5/2/23.
//////
////
////import Foundation
////import UIKit
//import GoogleAPIClientForREST
//
//class ViewController: UIViewController {
//
//    // Initialize the Google Photos Library service
////    let service = GTLRService()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Set the OAuth 2.0 access token for the service
////        let token = "YOUR_ACCESS_TOKEN_HERE"
////        service.authorizer = GTMFetcherAuthorization(fromToken: token)
////        service.authorizer = GTMFe
//        // Construct a query to retrieve the user's photos
//        //let query = GTLRPhotosLibraryQuery_ForYouPhotosList.query()
//        let query = GTLRBatchQuery().query(forRequestID: <#T##String#>)
//
//        // Send the query to the service
//        service.executeQuery(query) { [weak self] (ticket, response, error) in
//            if let error = error {
//                // Handle the error
//                print("Error retrieving photos: \(error.localizedDescription)")
//                return
//            }
//
//            // Cast the response to a GTLRPhotosLibrary_ForYouPhotosList object
//            guard let photosList = response as? GTLRPhotosLibrary_ForYouPhotosList else {
//                print("Invalid response type")
//                return
//            }
//
//            // Iterate over the list of photos and display them in your app UI
//            for photo in photosList.photos ?? [] {
//                if let baseUrl = photo.baseUrl {
//                    // Use an image loading library to download and display the photo
//                    // For example, using SDWebImage:
//                    // let imageView = UIImageView()
//                    // imageView.sd_setImage(with: URL(string: baseUrl), completed: nil)
//                }
//            }
//        }
//    }
//}
//
//
//
//
//
//
