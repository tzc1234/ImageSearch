//
//  FlickrAPITests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 14/08/2022.
//

import XCTest
@testable import ImageSearchDemo

class FlickrAPITests: XCTestCase {

    func test_searchPhotosEndPoint_isCorrect() {
        let client = HttpClientSpy()
        let sut = FlickrAPI(client: client)
        let searchTerm = "aaa"
        let page = 1
        
        sut.searchPhotos(by: "aaa", page: 1, completion: { _ in })
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

    func test_searchPhotosEndPoint_composeToValidURL() {
        let client = HttpClientSpy()
        let sut = FlickrAPI(client: client)
        
        sut.searchPhotos(by: "aaa", page: 1, completion: { _ in })
        let ep = client.endPoint as! FlickrEndPoint
        let url = client.url
        
        XCTAssertEqual(url?.absoluteString, "https://www.flickr.com/services/rest/?api_key=\(ep.apiKey)&method=flickr.photos.search&text=aaa&page=1&per_page=20&format=json")
    }
    
    func test_searchPhotos_handleInvalidURL() {
        let invalidUrlErr = NetworkError.invalidURL
        let client = FailureHttpClientStub(networkErr: invalidUrlErr)
        let sut = FlickrAPI(client: client)
        
        var networkErr: NetworkError?
        sut.searchPhotos(by: "aaa", page: 1) { result in
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
        let flickrError = flickrError
        let client = FailureHttpClientStub(flickrError: flickrError)
        let sut = FlickrAPI(client: client)
        
        var networkErr: NetworkError?
        sut.searchPhotos(by: "aaa", page: 1) { result in
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
        let searchPotos = SearchPhotos(photos: photos, stat: "ok")
        let client = SuccessHttpClientStub(searchPhotos: searchPotos)
        let sut = FlickrAPI(client: client)
        
        var sp: SearchPhotos?
        sut.searchPhotos(by: "aaa", page: 1) { result in
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
        let searchPotos = SearchPhotos(photos: photos, stat: "ok")
        let client = SuccessHttpClientStub(searchPhotos: searchPotos)
        let sut = FlickrAPI(client: client)
        
        var sp: SearchPhotos?
        sut.searchPhotos(by: "aaa", page: 1) { result in
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
        let searchPotos = SearchPhotos(photos: photos, stat: "ok")
        let client = SuccessHttpClientStub(searchPhotos: searchPotos)
        let sut = FlickrAPI(client: client)
        
        var sp: SearchPhotos?
        sut.searchPhotos(by: "aaa", page: 1) { result in
            switch result {
            case .success(let searchPhotos):
                sp = searchPhotos
            default:
                break
            }
        }
        
        XCTAssertEqual(sp, searchPotos)
    }
    
    func test_photoDataEndPoint_isCorrect() {
        let client = HttpClientSpy()
        let sut = FlickrAPI(client: client)
        
        sut.getPhotoData(by: makePhoto(id: "id0"), completion: { _ in })
        let ep = client.endPoint as! FlickrEndPoint
        
        XCTAssertEqual(ep.scheme, "https", "scheme")
        XCTAssertEqual(ep.path, "/server/id0_secret_b.jpg", "path")
        XCTAssertEqual(ep.baseURL, "live.staticflickr.com", "baseURL")
        XCTAssertEqual(ep.method, "get", "method")
        XCTAssertTrue(ep.flickrMethod.isEmpty, "flickrMethod")
        XCTAssertNil(ep.queryItems, "queryItems")
    }
    
    func test_photoDataEndPoint_composeToValidURL() {
        let client = HttpClientSpy()
        let sut = FlickrAPI(client: client)
        
        sut.getPhotoData(by: makePhoto(id: "id0"), completion: { _ in })
        let url = client.url
        
        XCTAssertEqual(url?.absoluteString, "https://live.staticflickr.com/server/id0_secret_b.jpg")
    }
    
    func test_getPhotoData_completeWithInvalidUrlError() {
        let error = NetworkError.invalidURL
        let client = FailureHttpClientStub(networkErr: error)
        let sut = FlickrAPI(client: client)
        
        var networkError: NetworkError?
        sut.getPhotoData(by: makePhoto(id: "id0")) { result in
            switch result {
            case .failure(let error):
                networkError = error
            default:
                break
            }
        }
        
        XCTAssertEqual(networkError?.errorMessage, error.errorMessage)
    }
    
    func test_getPhotoData_completeWithData() {
        let imageData = (UIImage(systemName: "photo")?.pngData())!
        let client = SuccessHttpClientStub(imageData: imageData)
        let sut = FlickrAPI(client: client)
        
        var photoData: Data?
        sut.getPhotoData(by: makePhoto(id: "id0")) { result in
            switch result {
            case .success(let data):
                photoData = data
            default:
                break
            }
        }
        
        XCTAssertEqual(photoData, imageData)
    }
    
    func test_searchPhotos_completeWithInvalidServerResponseError() {
        let error = NetworkError.invalidServerResponse
        let client = FailureHttpClientStub(networkErr: error)
        let sut = FlickrAPI(client: client)
        
        var networkError: NetworkError?
        sut.searchPhotos(by: "aaa", page: 1) { result in
            switch result {
            case .failure(let error):
                networkError = error
            default:
                break
            }
        }
        
        XCTAssertEqual(networkError?.errorMessage, error.errorMessage)
    }
    
    func test_getPhotoData_completeWithInvalidServerResponseError() {
        let error = NetworkError.invalidServerResponse
        let client = FailureHttpClientStub(networkErr: error)
        let sut = FlickrAPI(client: client)
        
        var networkError: NetworkError?
        sut.getPhotoData(by: makePhoto(id: "id0")) { result in
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

// MARK: - Helpers
extension FlickrAPITests {
    func makePhoto(id: String) -> Photo {
        Photo(id: id, owner: "owner", secret: "secret", server: "server", farm: 0, title: "title", ispublic: 0, isfriend: 0, isfamily: 0)
    }
    
    var flickrError: FlickrError {
        FlickrError(stat: "fail", code: 100, message: "Invalid API Key (Key has invalid format)")
    }
}

class HttpClientSpy: HttpClient {
    private(set) var endPoint: EndPoint?
    private(set) var url: URL?
    
    func request<T>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        self.endPoint = endPoint
        self.url = getURL(by: endPoint)
    }
    
    func requestData(endPoint: EndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        self.endPoint = endPoint
        self.url = getURL(by: endPoint)
    }
    
    private func getURL(by endPoint: EndPoint) -> URL? {
        var components = URLComponents()
        components.scheme = endPoint.scheme
        components.host = endPoint.baseURL
        components.path = endPoint.path
        components.queryItems = endPoint.queryItems
        return components.url
    }
}

class FailureHttpClientStub: HttpClient {
    private(set) var networkErr: NetworkError
    
    init(networkErr: NetworkError) {
        self.networkErr = networkErr
    }
    
    init(flickrError: FlickrError) {
        self.networkErr = NetworkError.flickrError(code: flickrError.code, message: flickrError.message)
    }
    
    func request<T>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        completion(.failure(networkErr))
    }
    
    func requestData(endPoint: EndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        completion(.failure(networkErr))
    }
}

class SuccessHttpClientStub: HttpClient {
    private(set) var searchPhotos: SearchPhotos?
    private(set) var imageData: Data?
    
    init(searchPhotos: SearchPhotos? = nil, imageData: Data? = nil) {
        self.searchPhotos = searchPhotos
        self.imageData = imageData
    }
    
    func request<T>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        completion(.success(searchPhotos as! T))
    }
    
    func requestData(endPoint: EndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        completion(.success(imageData!))
    }
}

