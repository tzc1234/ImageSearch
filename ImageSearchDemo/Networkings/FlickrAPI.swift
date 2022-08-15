//
//  FlickrAPI.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 14/08/2022.
//

import Foundation

class FlickrAPI {
    let client: HttpClient
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func searchPhotos(by searchTerm: String, page: Int, completion: @escaping (Result<SearchPhotos, NetworkError>) -> Void) {
        client.request(endPoint: FlickrEndPoint.searchPhotos(searchTerm: searchTerm, page: page), completion: completion)
    }
    
    func getPhotoData(by photo: Photo, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        client.requestData(endPoint: FlickrEndPoint.photoData(photo: photo), completion: completion)
    }
}
