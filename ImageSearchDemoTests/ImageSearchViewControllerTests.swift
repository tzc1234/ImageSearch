//
//  ImageSearchViewControllerTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 07/08/2022.
//

import XCTest
import Combine

protocol DataService: AnyObject {
    func fetchImages() -> AnyPublisher<[ImageViewModel], Error>
}

struct ImageViewModel {
    let image: UIImage?
    let title: String
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
        fetchImages()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
    
    private func fetchImages() {
        service.fetchImages()
            .receive(on: RunLoop.main)
            .sink { completion in
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
    
    func test_zeroTableViewCell() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        executeRunLoop()
        
        XCTAssertEqual(numberOfRows(tableView: sut.tableView, section: 0), 0)
    }
    
    func test_oneTableViewCell_ensureTitleCorrect() {
        let imageViewModels = [
            ImageViewModel(image: nil, title: "title 0")
        ]
        let service = ServiceStub(imageViewModels: imageViewModels)
        let sut = makeSUT(service: service)
        
        sut.loadViewIfNeeded()
        executeRunLoop()
        
        XCTAssertEqual(numberOfRows(tableView: sut.tableView, section: 0), 1, "number of rows")
        let cell = sut.getCell(row: 0, section: 0)
        XCTAssertEqual(cell?.titleLabel.text, "title 0", "title")
    }
    
    func test_threeTableViewCells_ensureTitlesAllCorrect() {
        let imageViewModels = [
            ImageViewModel(image: nil, title: "title 0"),
            ImageViewModel(image: nil, title: "title 1"),
            ImageViewModel(image: nil, title: "title 2")
        ]
        let service = ServiceStub(imageViewModels: imageViewModels)
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
    
}

// MARK: - Helpers
extension ImageSearchViewControllerTests {
    func makeSUT(service: DataService = ServiceStub(imageViewModels: [])) -> ImageSearchViewController {
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
}

private extension ImageSearchViewController {
    func getCell(row: Int, section: Int) -> ImageTableViewCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: .init(row: row, section: section)) as? ImageTableViewCell
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

private class ServiceStub: DataService {
    private(set) var imageViewModels: [ImageViewModel]
    
    init(imageViewModels: [ImageViewModel]) {
        self.imageViewModels = imageViewModels
    }
    
    func fetchImages() -> AnyPublisher<[ImageViewModel], Error> {
        Just(imageViewModels).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
