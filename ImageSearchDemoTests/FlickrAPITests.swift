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

enum NetworkError: Error {
    case invalidURL
    case flickrError(code: Int, message: String)
    
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .flickrError(let code, let message):
            return "Code: \(code), \(message)"
        }
    }
}

protocol HttpClient {
    func request<T: Codable>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void)
    func requestData(endPoint: EndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

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
        let invalidUrlErr = NetworkError.invalidURL
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
        
        XCTAssertEqual(networkErr?.errorMessage, "Invalid URL.")
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
        
        XCTAssertEqual(sp, searchPotos)
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
        
        XCTAssertEqual(sp, searchPotos)
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
        
        XCTAssertEqual(sp, searchPotos)
    }
    
    func test_getPhotoData_checkValidUrl() {
        let photo = makePhoto(id: "id0")
        let client = HttpClientSpy()
        let sut = FlickrAPI(client: client)
        
        sut.getPhotoData(endPoint: .photoData(photo: photo), completion: { _ in })
        let url = client.url
        
        XCTAssertEqual(url?.absoluteString, "https://live.staticflickr.com/server/id0_secret_b.jpg")
    }
    
    func test_getPhotoData_completeWithInvalidUrlError() {
        let photo = makePhoto(id: "id0")
        let error = NetworkError.invalidURL
        let client = FailureHttpClient(networkErr: error)
        let sut = FlickrAPI(client: client)
        
        var networkError: NetworkError?
        sut.getPhotoData(endPoint: .photoData(photo: photo)) { result in
            switch result {
            case .failure(let error):
                networkError = error
            default:
                break
            }
        }
        
        XCTAssertEqual(networkError?.errorMessage, error.errorMessage)
    }
    
}


// MARK: Helpers
extension FlickrAPITests {
    var searchPhotosEndPoint: FlickrEndPoint {
        return FlickrEndPoint.searchPhotos(searchTerm: "aaa", page: 1)
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
        
        self.url = components.url
    }
    
    func requestData(endPoint: EndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        self.endPoint = endPoint
        
        var components = URLComponents()
        components.scheme = endPoint.scheme
        components.host = endPoint.baseURL
        components.path = endPoint.path
        components.queryItems = endPoint.queryItems
        
        self.url = components.url
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
    
    func requestData(endPoint: EndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        completion(.failure(networkErr))
    }
}

class SuccessHttpClient: HttpClient {
    private(set) var searchPhotos: SearchPhotos
    private(set) var uiimage: UIImage
    
    init(searchPhotos: SearchPhotos, uiimage: UIImage = UIImage()) {
        self.searchPhotos = searchPhotos
        self.uiimage = uiimage
    }
    
    func request<T>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        completion(.success(searchPhotos as! T))
    }
    
    func requestData(endPoint: EndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        completion(.success(uiimage.pngData()!))
    }
}

