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
    
    func searchPhotos(endPoint: FlickrEndPoint, completion: @escaping (Result<SearchPhotos, NetworkError>) -> Void) {
        client.request(endPoint: endPoint, completion: completion)
    }
    
    func getPhotoData(endPoint: FlickrEndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        client.requestData(endPoint: endPoint, completion: completion)
    }
}
