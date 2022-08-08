//
//  ImageTableViewCellTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 08/08/2022.
//

import XCTest

class ImageTableViewCell: UITableViewCell {
    static let identifier = String(describing: ImageTableViewCell.self)
    
    lazy var photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    var viewModel: ImageViewModel? {
        didSet {
            photoImageView.image = viewModel?.image
            titleLabel.text = viewModel?.title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
    }
}

class ImageTableViewCellTests: XCTestCase {

    func test_titleLabelAndPhotoImageView_ensureImageViewAddedToContentViewSubviews() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.contentView.subviews.contains(sut.titleLabel))
        XCTAssertTrue(sut.contentView.subviews.contains(sut.photoImageView))
    }
    
    func test_titleLabel_ensureTitleLabelTextIsSameAsViewModelOne() {
        let sut = makeSUT()
        let viewModel = ImageViewModel(image: nil, title: "dummy title")
        
        sut.viewModel = viewModel
        
        XCTAssertEqual(sut.titleLabel.text, "dummy title")
    }
    
    func test_photoImageView_ensureImageIsTheSameAsViewModelOne() {
        let sut = makeSUT()
        let image = UIImage()
        let viewModel = ImageViewModel(image: image, title: "")
        
        sut.viewModel = viewModel
        
        XCTAssertIdentical(sut.photoImageView.image, image)
    }
    
}

// MARK: - Helpers
extension ImageTableViewCellTests {
    func makeSUT() -> ImageTableViewCell {
        let cell = ImageTableViewCell(style: .default, reuseIdentifier: ImageTableViewCell.identifier)
        return cell
    }
}
