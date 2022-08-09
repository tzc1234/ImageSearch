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
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .red
        return iv
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.backgroundColor = .green
        return l
    }()
    
    var viewModel: ImageViewModel? {
        didSet {
            photoImageView.image = viewModel?.image
            titleLabel.text = viewModel?.title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            photoImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 6),
            
            titleLabel.widthAnchor.constraint(equalTo: photoImageView.widthAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
