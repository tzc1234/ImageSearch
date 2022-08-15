//
//  NetworkError.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 14/08/2022.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case flickrError(code: Int, message: String)
    case invalidServerResponse
    
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .flickrError(let code, let message):
            return "Code: \(code), \(message)"
        case .invalidServerResponse:
            return "Invalid server response."
        }
    }
}
