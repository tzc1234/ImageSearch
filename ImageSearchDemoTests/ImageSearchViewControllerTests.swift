//
//  ImageSearchViewControllerTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 07/08/2022.
//

import XCTest

class ImageSearchViewController: UIViewController {
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Images"
        navigationItem.searchController = searchController
    }
    
}

class ImageSearchViewControllerTests: XCTestCase {

    func test_titleIsSearchImages() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "Search Images")
    }
    
    func test_searchControllerNotNil() {
        let sut = makeSUT()
        
        XCTAssertNotNil(sut.searchController)
    }

    func test_connectSearchControllerProperly() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.navigationItem.searchController, sut.searchController)
    }
    
}

// MARK: - Helpers
extension ImageSearchViewControllerTests {
    func makeSUT() -> ImageSearchViewController {
        let sut = ImageSearchViewController()
        
        return sut
    }
}
