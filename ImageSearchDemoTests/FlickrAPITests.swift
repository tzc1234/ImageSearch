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
    func request<T: Codable>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void)
}

class FlickrAPI {
    let client: HttpClient
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func searchImages(endPoint: FlickrEndPoint, completion: @escaping (Result<SearchPhotos, NetworkError>) -> Void) {
        client.request(endPoint: endPoint, completion: completion)
    }
}

struct SearchPhotos: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page, pages, perpage, total: Int
    let photo: [Photo]
}

struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}

class FlickrAPITests: XCTestCase {

    func test_endPoint_isCorrect() {
        let client = HttpClientSpy()
        let sut = FlickrAPI(client: client)
        let searchTerm = "aaa"
        let page = 1
        
        sut.searchImages(endPoint: .searchImages(searchTerm: searchTerm, page: page), completion: { _ in })
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
        let client = HttpClientSpy()
        let sut = FlickrAPI(client: client)
        
        sut.searchImages(endPoint: searchImagesEndPoint, completion: { _ in })
        let ep = client.endPoint as! FlickrEndPoint
        let url = client.url
        
        XCTAssertEqual(url?.absoluteString, "https://www.flickr.com/services/rest/?api_key=\(ep.apiKey)&method=flickr.photos.search&text=aaa&page=1&per_page=20&format=json")
    }
    
    func test_searchImages_handNetworkError() {
        let client = FailureHttpClient(networkErr: .invalidURL)
        let sut = FlickrAPI(client: client)
        
        var networkErr: NetworkError?
        sut.searchImages(endPoint: searchImagesEndPoint) { result in
            switch result {
            case .success:
                break
            case .failure(let err):
                networkErr = err
            }
        }
        
        XCTAssertEqual(networkErr, NetworkError.invalidURL)
    }
    
}

// MARK: Helpers
extension FlickrAPITests {
    var searchImagesEndPoint: FlickrEndPoint {
        .searchImages(searchTerm: "aaa", page: 1)
    }
}

class HttpClientSpy: HttpClient {
    private(set) var endPoint: EndPoint?
    private(set) var url: URL?
    
    func request<T>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        self.endPoint = endPoint
        
        var components = URLComponents()
        components.scheme = endPoint.scheme
        components.host = endPoint.baseURL
        components.path = endPoint.path
        components.queryItems = endPoint.queryItems
        url = components.url
    }
}

class FailureHttpClient: HttpClient {
    private(set) var networkErr: NetworkError
    
    init(networkErr: NetworkError) {
        self.networkErr = networkErr
    }
    
    func request<T>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        completion(.failure(networkErr))
    }
}
