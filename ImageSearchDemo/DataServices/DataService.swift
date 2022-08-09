//
//  DataService.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 09/08/2022.
//

import Foundation
import Combine

protocol DataService: AnyObject {
    func fetchImages(searchTerm: String, page: Int) -> AnyPublisher<[ImageViewModel], Error>
}

class PreviewService: DataService {
    let imageViewModels = [
        ImageViewModel(image: nil, title: "Title 0\n2nd row"),
        ImageViewModel(image: nil, title: "Title 1"),
        ImageViewModel(image: nil, title: "Title 2")
    ]
    
    init() {}
    
    func fetchImages(searchTerm: String, page: Int) -> AnyPublisher<[ImageViewModel], Error> {
        return Just(imageViewModels).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

