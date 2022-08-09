//
//  LoadingViewTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 09/08/2022.
//

import XCTest
@testable import ImageSearchDemo

class LoadingViewTests: XCTestCase {

    func test_indicator_initalProperly() {
        let sut = makeSUT()
        
        XCTAssertNotNil(sut.indicator)
    }
    
    func test_addToViewAndIndicatorIsAnimating() {
        let sut = makeSUT()
        let view = UIView()
        
        sut.add(to: view)
        
        XCTAssertTrue(view.subviews.contains(sut), "subviews")
        XCTAssertTrue(sut.indicator.isAnimating, "indicator.isAnimating")
    }
    
    func test_removeFromViewAndIndicatorIsNotAnimating() {
        let sut = makeSUT()
        let view = UIView()
        
        sut.add(to: view)
        
        XCTAssertTrue(view.subviews.contains(sut))
        
        sut.remove(from: view)
        
        XCTAssertFalse(view.subviews.contains(sut), "subviews")
        XCTAssertFalse(sut.indicator.isAnimating, "indicator.isAnimating")
    }
}

// MARK: - Helpers
extension LoadingViewTests {
    func makeSUT() -> LoadingView {
        LoadingView()
    }
}
