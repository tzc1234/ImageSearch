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
    case searchPhotos(searchTerm: String, page: Int)
    
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
        case .searchPhotos:
            return "/services/rest/"
        }
    }
    
    var method: String {
        switch self {
        default:
            return "get"
        }
    }
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            .init(name: "api_key", value: apiKey)
        ]
        
        switch self {
        case .searchPhotos(let searchTerm, let page):
            items += [
                .init(name: "method", value: flickrMethod),
                .init(name: "text", value: "\(searchTerm)"),
                .init(name: "page", value: "\(page)"),
                .init(name: "per_page", value: "20"),
                .init(name: "format", value: format),
            ]
        }
        
        return items
    }
    
    var flickrMethod: String {
        switch self {
        case .searchPhotos:
            return "flickr.photos.search"
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
    case invalidURL(flickrMethod: String)
    case flickrError(code: Int, message: String)
    
    var errorMessage: String {
        switch self {
        case .invalidURL(let flickrMethod):
            return "Invalid URL of flickrMethod: \(flickrMethod)."
        case .flickrError(let code, let message):
            return "Code: \(code), \(message)"
        }
    }
}

protocol HttpClient {
    func request<T: Codable>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void)
}

class FlickrAPI {
    let client: HttpClient
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func searchPhotos(endPoint: FlickrEndPoint, completion: @escaping (Result<SearchPhotos, NetworkError>) -> Void) {
        client.request(endPoint: endPoint, completion: completion)
    }
}

struct SearchPhotos: Codable {
    let photos: Photos?
    let stat: String
    let code: Int?
    let message: String?
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
        
        sut.searchPhotos(endPoint: .searchPhotos(searchTerm: searchTerm, page: page), completion: { _ in })
        let ep = client.endPoint as! FlickrEndPoint
        
        XCTAssertEqual(ep.scheme, "https", "scheme")
        XCTAssertEqual(ep.path, "/services/rest/", "path")
        XCTAssertEqual(ep.baseURL, "www.flickr.com", "baseURL")
        XCTAssertEqual(ep.method, "get", "method")
        
        let queryItems: [URLQueryItem] = [
            .init(name: "api_key", value: ep.apiKey),
            .init(name: "method", value: "flickr.photos.search"),
            .init(name: "text", value: "\(searchTerm)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "per_page", value: "20"),
            .init(name: "format", value: "json"),
        ]
        
        XCTAssertEqual(ep.queryItems, queryItems, "queryItems")
    }

    func test_endPoint_composeToCorrectUrl() {
        let client = HttpClientSpy()
        let sut = FlickrAPI(client: client)
        
        sut.searchPhotos(endPoint: searchPhotosEndPoint, completion: { _ in })
        let ep = client.endPoint as! FlickrEndPoint
        let url = client.url
        
        XCTAssertEqual(url?.absoluteString, "https://www.flickr.com/services/rest/?api_key=\(ep.apiKey)&method=flickr.photos.search&text=aaa&page=1&per_page=20&format=json")
    }
    
    func test_searchPhotos_handleInvalidURL() {
        let invalidUrlErr = NetworkError.invalidURL(flickrMethod: "flickr.photos.search")
        let client = FailureHttpClient(networkErr: invalidUrlErr)
        let sut = FlickrAPI(client: client)
        
        var networkErr: NetworkError?
        sut.searchPhotos(endPoint: searchPhotosEndPoint) { result in
            switch result {
            case .failure(let err):
                networkErr = err
            default:
                break
            }
        }
        
        XCTAssertEqual(networkErr?.errorMessage, "Invalid URL of flickrMethod: flickr.photos.search.")
    }
    
    func test_searchPhotos_completeWithFlickrError() {
        let searchPotos = SearchPhotos(photos: nil, stat: "fail", code: 100, message: "Invalid API Key (Key has invalid format)")
        let client = FailureHttpClient(flickrErrorSearchPhotos: searchPotos)
        let sut = FlickrAPI(client: client)
        
        var networkErr: NetworkError?
        sut.searchPhotos(endPoint: searchPhotosEndPoint) { result in
            switch result {
            case .failure(let err):
                networkErr = err
            default:
                break
            }
        }
        
        XCTAssertEqual(networkErr?.errorMessage, "Code: 100, Invalid API Key (Key has invalid format)")
    }
    
    func test_searchPhotos_completeWithEmptySearchedPhotos() {
        let photos = Photos(page: 1, pages: 0, perpage: 20, total: 0, photo: [])
        let searchPotos = SearchPhotos(photos: photos, stat: "ok", code: nil, message: nil)
        let client = SuccessHttpClient(searchPhotos: searchPotos)
        let sut = FlickrAPI(client: client)
        
        var sp: SearchPhotos?
        sut.searchPhotos(endPoint: searchPhotosEndPoint) { result in
            switch result {
            case .success(let searchPhotos):
                sp = searchPhotos
            default:
                break
            }
        }
        
        XCTAssertEqual(sp?.stat, "ok", "state")
        XCTAssertEqual(sp?.photos?.photo.count, 0, "photo count")
        XCTAssertEqual(sp?.photos?.page, 1, "page")
        XCTAssertEqual(sp?.photos?.pages, 0 , "pages")
        XCTAssertEqual(sp?.photos?.perpage, 20, "perpage")
        XCTAssertEqual(sp?.photos?.total, 0, "total")
    }
    
    func test_searchPhotos_completeWithOneSearchedPhotos() {
        let photos = Photos(page: 1, pages: 1, perpage: 20, total: 1, photo: [makePhoto(id: "id0")])
        let searchPotos = SearchPhotos(photos: photos, stat: "ok", code: nil, message: nil)
        let client = SuccessHttpClient(searchPhotos: searchPotos)
        let sut = FlickrAPI(client: client)
        
        var sp: SearchPhotos?
        sut.searchPhotos(endPoint: searchPhotosEndPoint) { result in
            switch result {
            case .success(let searchPhotos):
                sp = searchPhotos
            default:
                break
            }
        }
        
        let p = sp?.photos?.photo.first
        
        XCTAssertEqual(sp?.stat, "ok", "state")
        XCTAssertEqual(sp?.photos?.photo.count, 1, "photo count")
        XCTAssertEqual(sp?.photos?.page, 1, "page")
        XCTAssertEqual(sp?.photos?.pages, 1 , "pages")
        XCTAssertEqual(sp?.photos?.perpage, 20, "perpage")
        XCTAssertEqual(sp?.photos?.total, 1, "total")
        
        XCTAssertEqual(p?.id, "id0", "id")
        XCTAssertEqual(p?.owner, "owner", "owner")
        XCTAssertEqual(p?.secret, "secret", "secret")
        XCTAssertEqual(p?.server, "server", "server")
        XCTAssertEqual(p?.farm, 0, "farm")
        XCTAssertEqual(p?.title, "title", "title")
        XCTAssertEqual(p?.ispublic, 0, "ispublic")
        XCTAssertEqual(p?.isfriend, 0, "isfriend")
        XCTAssertEqual(p?.isfamily, 0, "isfamily")
    }
    
    func test_searchPhotos_completeWithThreeSearchPhotos() {
        let photos = Photos(page: 1, pages: 1, perpage: 20, total: 3, photo: [
            makePhoto(id: "id0"),
            makePhoto(id: "id1"),
            makePhoto(id: "id2")
        ])
        let searchPotos = SearchPhotos(photos: photos, stat: "ok", code: nil, message: nil)
        let client = SuccessHttpClient(searchPhotos: searchPotos)
        let sut = FlickrAPI(client: client)
        
        var sp: SearchPhotos?
        sut.searchPhotos(endPoint: searchPhotosEndPoint) { result in
            switch result {
            case .success(let searchPhotos):
                sp = searchPhotos
            default:
                break
            }
        }
        
        let photoArr = (sp?.photos?.photo)!
        
        XCTAssertEqual(sp?.stat, "ok", "state")
        XCTAssertEqual(sp?.photos?.photo.count, 3, "photo count")
        XCTAssertEqual(sp?.photos?.page, 1, "page")
        XCTAssertEqual(sp?.photos?.pages, 1 , "pages")
        XCTAssertEqual(sp?.photos?.perpage, 20, "perpage")
        XCTAssertEqual(sp?.photos?.total, 3, "total")
        XCTAssertEqual(photoArr[0].id, "id0", "photo 0")
        XCTAssertEqual(photoArr[1].id, "id1", "photo 1")
        XCTAssertEqual(photoArr[2].id, "id2", "photo 2")
    }
    
}

// MARK: Helpers
extension FlickrAPITests {
    var searchPhotosEndPoint: FlickrEndPoint {
        .searchPhotos(searchTerm: "aaa", page: 1)
    }
    
    func makePhoto(id: String, owner: String = "owner", title: String = "title") -> Photo {
        Photo(id: id, owner: owner, secret: "secret", server: "server", farm: 0, title: title, ispublic: 0, isfriend: 0, isfamily: 0)
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
    
    init(flickrErrorSearchPhotos: SearchPhotos) {
        self.networkErr = NetworkError.flickrError(code: flickrErrorSearchPhotos.code!, message: flickrErrorSearchPhotos.message!)
    }
    
    func request<T>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        completion(.failure(networkErr))
    }
}

class SuccessHttpClient: HttpClient {
    private(set) var searchPhotos: SearchPhotos
    
    init(searchPhotos: SearchPhotos) {
        self.searchPhotos = searchPhotos
    }
    
    func request<T>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        completion(.success(searchPhotos as! T))
    }
}

