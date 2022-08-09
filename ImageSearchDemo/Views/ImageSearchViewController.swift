//
//  ImageSearchViewController.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 09/08/2022.
//

import UIKit
import Combine

class ImageSearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    let searchController = UISearchController()
    
    private(set) var tableView: UITableView = {
        let table = UITableView()
        table.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
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
        view.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        
        searchController.searchResultsUpdater = self
        tableView.dataSource = self
        tableView.delegate = self
        
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
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
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        fetchImages(searchTerm: text)
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
