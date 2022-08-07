//
//  ImageSearchViewControllerTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 07/08/2022.
//

import XCTest

class ImageSearchViewController: UIViewController, UISearchResultsUpdating {
    let searchController = UISearchController()
    private(set) var searchTerm = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Images"
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchTerm = text
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
    
    func test_connectSearchResultUpdater() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertIdentical(sut.searchController.searchResultsUpdater, sut)
    }
    
    func test_searchTerm_updtaeWhenInputTextToSearchBar() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.searchController.searchBar.text = "dummy search term"
        sut.searchController.searchResultsUpdater?.updateSearchResults(for: sut.searchController)
        
        XCTAssertEqual(sut.searchTerm, "dummy search term")
    }
    
}

// MARK: - Helpers
extension ImageSearchViewControllerTests {
    func makeSUT() -> ImageSearchViewController {
        let sut = ImageSearchViewController()
        
        return sut
    }
}
