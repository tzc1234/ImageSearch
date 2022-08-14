//
//  Models.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 14/08/2022.
//

import Foundation

struct SearchPhotos: Codable, Equatable {
    let photos: Photos?
    let stat: String
    let code: Int?
    let message: String?
}

struct Photos: Codable, Equatable {
    let page, pages, perpage, total: Int
    let photo: [Photo]
}

struct Photo: Codable, Equatable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
