//
//  EndPoint.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 14/08/2022.
//

import Foundation

protocol EndPoint {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var method: String { get }
}

enum FlickrEndPoint: EndPoint {
    case searchPhotos(searchTerm: String, page: Int)
    case photoData(photo: Photo)
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        case .photoData:
            return "live.staticflickr.com"
        default:
            return "www.flickr.com"
        }
    }
    
    var path: String {
        switch self {
        case .searchPhotos:
            return "/services/rest/"
        case .photoData(let photo):
            return "/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg"
        }
    }
    
    var method: String {
        switch self {
        default:
            return "get"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .searchPhotos(let searchTerm, let page):
            return [
                .init(name: "api_key", value: apiKey),
                .init(name: "method", value: flickrMethod),
                .init(name: "text", value: "\(searchTerm)"),
                .init(name: "page", value: "\(page)"),
                .init(name: "per_page", value: "20"),
                .init(name: "format", value: format),
            ]
        case .photoData:
            return nil
        }
    }
    
    var flickrMethod: String {
        switch self {
        case .searchPhotos:
            return "flickr.photos.search"
        case .photoData:
            return ""
        }
    }
    
    var apiKey: String {
        "API_KEY"
    }
    
    var format: String {
        switch self {
        default:
            return "json"
        }
    }
}
