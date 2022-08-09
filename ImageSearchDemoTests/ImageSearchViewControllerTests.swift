//
//  ImageSearchViewControllerTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 07/08/2022.
//

import XCTest
import Combine
@testable import ImageSearchDemo

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
    
    func test_tableView_ensureDataSourceAndDelegateNotNil() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertNotNil(sut.tableView.delegate)
    }
    
    func test_tableView_ensureAddedToSubviews() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.view.subviews.contains(sut.tableView))
    }
    
    func test_tableView_zeroCellAfterInital() {
        let viewModels = [ImageViewModel(image: nil, title: "dummay title")]
        let service = ServiceStub(fetchImagesFuncution: fetchImages(by: viewModels))
        let sut = makeSUT(service: service)
        
        sut.loadViewIfNeeded()
        executeRunLoop()
        
        XCTAssertEqual(service.lastReveicedSearchTerm, "", "lastReveicedSearchTerm")
        XCTAssertEqual(numberOfRows(tableView: sut.tableView, section: 0), 0, "numberOfRows")
    }
    
    
    func test_tableView_oneTableViewCell_ensureTitleCorrect() {
        let viewModels = [ImageViewModel(image: nil, title: "dummay title")]
        let service = ServiceStub(fetchImagesFuncution: fetchImages(by: viewModels))
        let sut = makeSUT(service: service)
        XCTAssertEqual(service.lastReveicedSearchTerm, "", "lastReveicedSearchTerm")
        
        sut.loadViewIfNeeded()
        sut.updateSearchBarText(to: "dummy search term")
        executeRunLoop()
        
        XCTAssertEqual(service.lastReveicedSearchTerm, "dummy search term", "lastReveicedSearchTerm")
        let cell = sut.getCell(row: 0, section: 0)
        XCTAssertEqual(cell?.titleLabel.text, "dummay title", "title")
    }
    
    func test_threeTableViewCells_ensureTitlesAllCorrect() {
        let imageViewModels = [
            ImageViewModel(image: nil, title: "title 0"),
            ImageViewModel(image: nil, title: "title 1"),
            ImageViewModel(image: nil, title: "title 2")
        ]
        let service = ServiceStub(fetchImagesFuncution: fetchImages(by: imageViewModels))
        let sut = makeSUT(service: service)

        sut.loadViewIfNeeded()
        sut.updateSearchBarText(to: "dummy search term")
        executeRunLoop()

        let cell0 = sut.getCell(row: 0, section: 0)
        let cell1 = sut.getCell(row: 1, section: 0)
        let cell2 = sut.getCell(row: 2, section: 0)
        XCTAssertEqual(cell0?.titleLabel.text, "title 0", "cell 0 title")
        XCTAssertEqual(cell1?.titleLabel.text, "title 1", "cell 1 title")
        XCTAssertEqual(cell2?.titleLabel.text, "title 2", "cell 2 title")
    }

    func test_loadingView_showHideDependsOnFetchingImages() {
        let imageViewModels = [ImageViewModel(image: nil, title: "title 0")]
        let service = ServiceStub(fetchImagesFuncution: fetchImages(by: imageViewModels))
        let sut = makeSUT(service: service)

        sut.loadViewIfNeeded()
        sut.updateSearchBarText(to: "dummy search term")

        // Loading
        XCTAssertEqual(sut.view.subviews.filter({ $0 is LoadingView }).count, 1)
        
        executeRunLoop()

        // End loading
        XCTAssertEqual(sut.view.subviews.filter({ $0 is LoadingView }).count, 0)
    }

    func test_searchTerm_changeToTriggerSearchImages() {
        let service = ServiceStub(fetchImagesFuncution: fetchImages(by: []))
        let sut = makeSUT(service: service)

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(service.lastReveicedSearchTerm, "", "lastReveicedSearchTerm")

        // Change fetched ImageViewModels
        service.fetchImagesFuncution = fetchImages(by: [
            ImageViewModel(image: nil, title: "title 0")
        ])
        // Change search term
        sut.updateSearchBarText(to: "dummy search term")

        executeRunLoop()

        XCTAssertEqual(service.lastReveicedSearchTerm, "dummy search term", "lastReveicedSearchTerm")
        XCTAssertEqual(sut.getCell(row: 0, section: 0)?.titleLabel.text, "title 0", "cell title")
    }
    
}

// MARK: - Helpers

extension ImageSearchViewControllerTests {
    func makeSUT() -> ImageSearchViewController {
        let service = ServiceStub(fetchImagesFuncution: fetchImages(by: []))
        return makeSUT(service: service)
    }
    
    func makeSUT(service: DataService) -> ImageSearchViewController {
        let sut = ImageSearchViewController(service: service)
        return sut
    }
    
    func numberOfRows(tableView: UITableView?, section: Int) -> Int? {
        guard let tableView = tableView else { return nil }
        return tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func executeRunLoop() {
        RunLoop.main.run(until: Date())
    }
    
    func fetchImages(by imageViewModels: [ImageViewModel]) -> FetchImagesFuction {
        { Just(imageViewModels).setFailureType(to: Error.self).eraseToAnyPublisher() }
    }
}

private extension ImageSearchViewController {
    func getCell(row: Int, section: Int) -> ImageTableViewCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: .init(row: row, section: section)) as? ImageTableViewCell
    }
    
    func updateSearchBarText(to text: String) {
        searchController.searchBar.text = text
    }
}

typealias FetchImagesFuction = (() -> AnyPublisher<[ImageViewModel], Error>)

private class ServiceStub: DataService {
    var fetchImagesFuncution: FetchImagesFuction
    private(set) var lastReveicedSearchTerm = ""
    
    init(fetchImagesFuncution: @escaping FetchImagesFuction) {
        self.fetchImagesFuncution = fetchImagesFuncution
    }
    
    func fetchImages(searchTerm: String, page: Int) -> AnyPublisher<[ImageViewModel], Error> {
        lastReveicedSearchTerm = searchTerm
        return fetchImagesFuncution()
    }
}
