//
//  API.swift
//  VirtualTourist
//
//  Created by Lama AlMayouf on 8/12/20.
//  Copyright © 2020 Lama AlMayouf. All rights reserved.
//

import Foundation
import UIKit

class API{
    
    class func loadImageData(page: Int = 1, lat: Double, lon: Double, completion: @escaping (String?,[String]?)->Void){
        
        let url = API.Endpoints.photosSearch(page: page, lat: lat, lon: lon).url

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            var errorString: String?
            var constructedURLS: [String]?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode{
               if statusCode >= 200 && statusCode < 300{
                do{
                    let responseObj = try JSONDecoder().decode(PhotSearchResponse.self, from: data!)
                    constructedURLS = self.constructURLS(photos: responseObj.photos.photo)
                }catch{
                    errorString = error.localizedDescription
                }
               }else{
                    errorString = "Couldn't load images"
                }
            }else{
                errorString = "Check your internet connection"
            }
            DispatchQueue.main.async{
                completion(errorString, constructedURLS)
            }
        }.resume()
    }
    
    class func constructURLS(photos: [Photo])-> [String]{
        var urls = [String]()
        for photo in photos{
            let url =  "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
            urls.append(url)
        }

        return urls
    }
}


extension API{
    
    enum Endpoints{
        private static let base = "https://api.flickr.com/services/rest"
        private static let key = "84c943979334c3dd19e7fa8a0df622b7"
        
        case photosSearch(page: Int , lat:Double, lon: Double)
        
        var stringValue: String{
            switch self {
            case let .photosSearch(page, lat, lon):
                return API.Endpoints.base +
                "?method=flickr.photos.search&api_key=\(API.Endpoints.key)&lat=\(lat)&lon=\(lon)&page=\(page)&format=json&accuracy=11&nojsoncallback=1"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
}

