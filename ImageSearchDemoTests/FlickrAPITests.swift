//
//  FlickrAPITests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 14/08/2022.
//

import XCTest

protocol EndPoint {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: String { get }
}

enum FlickrEndPoint: EndPoint {
    case searchImages(searchTerm: String, page: Int)
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return "www.flickr.com"
        }
    }
    
    var path: String {
        switch self {
        case .searchImages:
            return "/services/rest/"
        }
    }
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            .init(name: "api_key", value: apiKey)
        ]
        
        switch self {
        case .searchImages(let searchTerm, let page):
            items += [
                .init(name: "method", value: "flickr.photos.search"),
                .init(name: "text", value: "\(searchTerm)"),
                .init(name: "page", value: "\(page)"),
                .init(name: "per_page", value: "20"),
                .init(name: "format", value: format),
            ]
        }
        
        return items
    }
    
    var method: String {
        switch self {
        default:
            return "get"
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

enum NetworkError: Error {
    case invalidURL
}

protocol HttpClient {
    func request<T: Codable>(endPoint: EndPoint, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void)
}

class FailureHttpClientSpy: HttpClient {
    private(set) var endPoint: EndPoint?
    private(set) var url: URL?
    
    func request<T>(endPoint: EndPoint, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        self.endPoint = endPoint
        
        var components = URLComponents()
        components.scheme = endPoint.scheme
        components.host = endPoint.baseURL
        components.path = endPoint.path
        components.queryItems = endPoint.queryItems
        
        url = components.url
        
        completion(.failure(NetworkError.invalidURL))
    }
}

class FlickrAPI {
    let client: HttpClient
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func searchImages(endPoint: EndPoint) {
        client.request(endPoint: endPoint, type: String.self, completion: {_ in})
    }
}

class FlickrAPITests: XCTestCase {

    func test_endPoint_isCorrect() {
        let client = FailureHttpClientSpy()
        let sut = FlickrAPI(client: client)
        let searchTerm = "aaa"
        let page = 1
        
        sut.searchImages(endPoint: FlickrEndPoint.searchImages(searchTerm: searchTerm, page: page))
        let ep = client.endPoint as! FlickrEndPoint
        
        let queryItems: [URLQueryItem] = [
            .init(name: "api_key", value: ep.apiKey),
            .init(name: "method", value: "flickr.photos.search"),
            .init(name: "text", value: "\(searchTerm)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "per_page", value: "20"),
            .init(name: "format", value: "json"),
        ]
        
        XCTAssertEqual(ep.scheme, "https", "scheme")
        XCTAssertEqual(ep.path, "/services/rest/", "path")
        XCTAssertEqual(ep.baseURL, "www.flickr.com", "baseURL")
        XCTAssertEqual(ep.method, "get", "method")
        XCTAssertEqual(ep.queryItems, queryItems, "queryItems")
    }

    func test_endPoint_composeToCorrectUrl() {
        let client = FailureHttpClientSpy()
        let sut = FlickrAPI(client: client)
        let searchTerm = "aaa"
        let page = 1
        
        sut.searchImages(endPoint: FlickrEndPoint.searchImages(searchTerm: searchTerm, page: page))
        let ep = client.endPoint as! FlickrEndPoint
        let url = client.url
        
        XCTAssertEqual(url?.absoluteString, "https://www.flickr.com/services/rest/?api_key=\(ep.apiKey)&method=flickr.photos.search&text=aaa&page=1&per_page=20&format=json")
    }
}
