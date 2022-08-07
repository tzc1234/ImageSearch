//
//  ImageSearchViewControllerTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 07/08/2022.
//

import XCTest
import Combine

class ImageSearchViewController: UIViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController()
    let searchTerm = CurrentValueSubject<String, Never>("")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Images"
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchTerm.send(searchController.searchBar.text ?? "")
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
    
    func test_searchTerm_initalValueShouldBeEmptyString() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let _ = sut.searchTerm
            .sink { searchTerm in
                XCTAssertEqual(searchTerm, "")
            }
    }
    
    func test_searchTerm_getUpdatedTextFromSearchTermPublisherProperly() {
        let sut = makeSUT()

        sut.loadViewIfNeeded()
        sut.searchController.searchBar.text = "dummy search term"
        sut.searchController.searchResultsUpdater?.updateSearchResults(for: sut.searchController)

        let _ = sut.searchTerm
            .sink { searchTerm in
                XCTAssertEqual(searchTerm, "dummy search term")
            }
    }
    
}

// MARK: - Helpers
extension ImageSearchViewControllerTests {
    func makeSUT() -> ImageSearchViewController {
        let sut = ImageSearchViewController()
        
        return sut
    }
}
