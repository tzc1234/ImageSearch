//
//  ImageTableViewCell.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 09/08/2022.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    static let identifier = String(describing: ImageTableViewCell.self)
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    let titleLabel: UILabel = {
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
