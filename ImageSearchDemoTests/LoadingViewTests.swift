//
//  LoadingViewTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 09/08/2022.
//

import XCTest

class LoadingView: UIView {
    static let shared = LoadingView()
    
    let indicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.startAnimating()
        return ind
    }()
    
    convenience init() {
        self.init(frame: .zero)
        indicator.center = center
    }
    
    func add(to view: UIView) {
        view.addSubview(self)
    }
    
    func remove(from view: UIView) {
        removeFromSuperview()
    }
}

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
