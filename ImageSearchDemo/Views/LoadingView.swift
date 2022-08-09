//
//  LoadingView.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 09/08/2022.
//

import UIKit

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
        backgroundColor = .darkGray.withAlphaComponent(0.7)
    }
    
    func add(to view: UIView) {
        view.addSubview(self)
    }
    
    func remove(from view: UIView) {
        removeFromSuperview()
    }
}
