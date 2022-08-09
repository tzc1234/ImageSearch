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

    func test_indicator_isAnimatingAfterInit() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.indicator.isAnimating)
    }
    
    func test_addToView() {
        let sut = makeSUT()
        let view = UIView()
        
        sut.add(to: view)
        
        XCTAssertTrue(view.subviews.contains(sut))
    }
    
    func test_removeFromView() {
        let sut = makeSUT()
        let view = UIView()
        
        sut.add(to: view)
        
        XCTAssertTrue(view.subviews.contains(sut))
        
        sut.remove(from: view)
        
        XCTAssertFalse(view.subviews.contains(sut))
    }
}

// MARK: - Helpers
extension LoadingViewTests {
    func makeSUT() -> LoadingView {
        LoadingView()
    }
}
