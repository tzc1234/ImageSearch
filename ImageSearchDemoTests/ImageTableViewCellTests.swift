//
//  ImageTableViewCellTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 08/08/2022.
//

import XCTest
@testable import ImageSearchDemo

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
