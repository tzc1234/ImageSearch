//
//  LoadingViewTests.swift
//  ImageSearchDemoTests
//
//  Created by Tsz-Lung on 09/08/2022.
//

import XCTest

class LoadingView: UIView {
    static let shared = LoadingView(frame: .zero)
    
    let indicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
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

}

// MARK: - Helpers
extension LoadingViewTests {
    func makeSUT() -> LoadingView {
        LoadingView()
    }
}
