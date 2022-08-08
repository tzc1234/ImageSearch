//
//  ImageSearchViewControllerTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 07/08/2022.
//

import XCTest
import Combine

class ImageSearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    let searchController = UISearchController()
    let searchTerm = CurrentValueSubject<String, Never>("")
    private(set) var tableView: UITableView = {
        let table = UITableView()
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Images"
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        tableView.dataSource = self
        tableView.delegate = self
        
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchTerm.send(searchController.searchBar.text ?? "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
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
        let spy = searchTermPublisherSpy(searchTerm: sut.searchTerm)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(spy.searchTerms, [""])
    }
    
    func test_searchTerm_getUpdatedTextFromSearchTermPublisherProperly() {
        let sut = makeSUT()
        let spy = searchTermPublisherSpy(searchTerm: sut.searchTerm)

        sut.loadViewIfNeeded()
        sut.searchController.searchBar.text = "dummy search term"

        XCTAssertEqual(spy.searchTerms, ["", "dummy search term"])
    }
    
    func test_tableView_ensureDataSourceAndDelegateNotNil() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertNotNil(sut.tableView.delegate)
    }
    
    func test_tableView_addedToSubview() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.view.subviews.contains(sut.tableView))
    }
    
}

// MARK: - Helpers
extension ImageSearchViewControllerTests {
    func makeSUT() -> ImageSearchViewController {
        let sut = ImageSearchViewController()
        
        return sut
    }
}

private class searchTermPublisherSpy {
    private(set) var searchTerms = [String]()
    private var subscription: AnyCancellable?
    
    init(searchTerm: CurrentValueSubject<String, Never>) {
        subscription = searchTerm.sink { [weak self] searchTerm in
            self?.searchTerms.append(searchTerm)
        }
    }
}
