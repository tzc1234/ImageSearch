//
//  ImageSearchViewControllerTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 07/08/2022.
//

import XCTest
import Combine

protocol DataService: AnyObject {
    func fetchImages(searchTerm: String, page: Int) -> AnyPublisher<[ImageViewModel], Error>
}

struct ImageViewModel {
    let image: UIImage?
    let title: String
}

class LoadingView: UIView {
    static let shared = LoadingView(frame: .zero)
    
    func add(to view: UIView) {
        view.addSubview(self)
    }
    
    func remove(from view: UIView) {
        removeFromSuperview()
    }
}

class ImageSearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    let searchController = UISearchController()
    let searchTerm = CurrentValueSubject<String, Never>("")
    private(set) var tableView: UITableView = {
        let table = UITableView()
        table.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.identifier)
        return table
    }()
    private var imageViewModels = [ImageViewModel]()
    private var subscriptions = Set<AnyCancellable>()
    
    private let service: DataService
    
    init(service: DataService) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Images"
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        tableView.dataSource = self
        tableView.delegate = self
        
        setupTableView()
        subscriptSearchTerm()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
    
    private func fetchImages(searchTerm: String, page: Int = 1) {
        LoadingView.shared.add(to: view)
        
        service.fetchImages(searchTerm: searchTerm, page: page)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                LoadingView.shared.remove(from: self.view)
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] imageViewModels in
                self?.imageViewModels = imageViewModels
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
    }
    
    private func subscriptSearchTerm() {
        searchTerm
            .sink { [weak self] term in
                self?.fetchImages(searchTerm: term)
            }
            .store(in: &subscriptions)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        searchTerm.send(searchController.searchBar.text ?? "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell
        else {
            return ImageTableViewCell()
        }
        
        cell.viewModel = imageViewModels[indexPath.row]
        
        return cell
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
        let spy = SearchTermPublisherSpy(searchTerm: sut.searchTerm)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(spy.searchTerms, [""])
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
    
    func test_tableView_zeroCellAfterInitalCall() {
        let service = ServiceStub(fetchImagesFuncution: fetchImages(by: []))
        let sut = makeSUT(service: service)
        
        sut.loadViewIfNeeded()
        executeRunLoop()
        
        XCTAssertEqual(service.fetchImagesTriggerCount, 1, "fetchImagesTriggerCount")
        XCTAssertEqual(service.lastReveicedSearchTerm, "", "lastReveicedSearchTerm")
        XCTAssertEqual(numberOfRows(tableView: sut.tableView, section: 0), 0, "numberOfRows")
    }
    
    
    func test_tableView_oneTableViewCell_ensureTitleCorrect() {
        let viewModels = [ImageViewModel(image: nil, title: "dummay title")]
        let service = ServiceStub(fetchImagesFuncution: fetchImages(by: viewModels))
        let sut = makeSUT(service: service)
        
        XCTAssertEqual(service.lastReveicedSearchTerm, "", "lastReveicedSearchTerm")
        
        sut.loadViewIfNeeded()
        sut.searchController.searchBar.text = "dummy search term"
        executeRunLoop()
        
        XCTAssertEqual(service.fetchImagesTriggerCount, 2, "fetchImagesTriggerCount")
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
        executeRunLoop()

        XCTAssertEqual(numberOfRows(tableView: sut.tableView, section: 0), 3, "number of rows")

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
        sut.searchController.searchBar.text = "dummy search term"

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
}

private class SearchTermPublisherSpy {
    private(set) var searchTerms = [String]()
    private var subscription: AnyCancellable?
    
    init(searchTerm: CurrentValueSubject<String, Never>) {
        subscription = searchTerm.sink { [weak self] searchTerm in
            self?.searchTerms.append(searchTerm)
        }
    }
}

typealias FetchImagesFuction = (() -> AnyPublisher<[ImageViewModel], Error>)

private class ServiceStub: DataService {
    var fetchImagesFuncution: FetchImagesFuction
    private(set) var lastReveicedSearchTerm = ""
    private(set) var fetchImagesTriggerCount = 0
    
    init(fetchImagesFuncution: @escaping FetchImagesFuction) {
        self.fetchImagesFuncution = fetchImagesFuncution
    }
    
    func fetchImages(searchTerm: String, page: Int) -> AnyPublisher<[ImageViewModel], Error> {
        fetchImagesTriggerCount += 1
        lastReveicedSearchTerm = searchTerm
        return fetchImagesFuncution()
    }
}
