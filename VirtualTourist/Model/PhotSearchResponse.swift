//
//  PhotSearchResponse.swift
//  VirtualTourist
//
//  Created by Lama AlMayouf on 8/13/20.
//  Copyright © 2020 Lama AlMayouf. All rights reserved.
//

import Foundation
struct PhotSearchResponse: Codable {
    let photos: Photos
    let stat: String
}
// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
