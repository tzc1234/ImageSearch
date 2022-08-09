//
//  LoadingView.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 09/08/2022.
//

import UIKit

class LoadingView: UIView {

    let indicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.translatesAutoresizingMaskIntoConstraints = false
        ind.color = .systemBlue
        return ind
    }()
    
    convenience init() {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
    }
    
    func add(to view: UIView) {
        view.addSubview(self)
        setConstraints(to: view)
        indicator.startAnimating()
    }
    
    func remove(from view: UIView) {
        indicator.stopAnimating()
        removeFromSuperview()
    }
    
    private func setConstraints(to superview: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
