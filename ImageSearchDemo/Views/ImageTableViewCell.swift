//
//  ImageTableViewCell.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 09/08/2022.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    static let identifier = String(describing: ImageTableViewCell.self)
    
    let shadowBgView: UIView = {
        let sbg = UIView()
        sbg.backgroundColor = .systemBackground
        sbg.layer.cornerRadius = 12
        sbg.layer.shadowColor = UIColor.systemGray3.cgColor
        sbg.layer.shadowOpacity = 1
        sbg.layer.shadowRadius = 2
        sbg.layer.shadowOffset = .init(width: 0, height: 3)
        return sbg
    }()
    let bgView: UIView = {
        let bg = UIView()
        bg.layer.cornerRadius = 12
        bg.layer.borderWidth = 1
        bg.layer.borderColor = UIColor.systemGray5.cgColor
        bg.clipsToBounds = true
        return bg
    }()
    let photoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "photo"))
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .light)
        l.numberOfLines = 0
        return l
    }()
    
    var viewModel: ImageViewModel? {
        didSet {
            photoImageView.image = viewModel?.image ?? UIImage(systemName: "photo")
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
        contentView.addSubview(shadowBgView)
        contentView.addSubview(bgView)
        bgView.addSubview(photoImageView)
        bgView.addSubview(titleLabel)
        
        shadowBgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shadowBgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shadowBgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            shadowBgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            shadowBgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            bgView.topAnchor.constraint(equalTo: shadowBgView.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: shadowBgView.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: shadowBgView.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: shadowBgView.bottomAnchor),

            photoImageView.topAnchor.constraint(equalTo: bgView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 0.5625),
            photoImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -6),

            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -6)
        ])
    }
}
