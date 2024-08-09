//
//  File.swift
//  PokemonAPI
//
//  Created by 신상규 on 8/7/24.
//

import UIKit
import SnapKit

class PoketmonCell: UICollectionViewCell {
    
    static let id = "PoketmonCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        setupLayout()
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.addSubview(imageView)
        imageView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureAppearance() {
            // 셀의 배경색을 하얀색으로 설정
            contentView.backgroundColor = .white
            
            // 셀의 테두리를 추가
            contentView.layer.borderColor = UIColor.gray.cgColor
            contentView.layer.borderWidth = 1.0
            contentView.layer.cornerRadius = 8.0
            contentView.layer.masksToBounds = true
        }
    
    func configure(with pokemon: Pokemon) {
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.id).png"
        if let imageUrl = URL(string: imageUrlString) {
            let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                        self?.adjustImageSize(image)
                    }
                }
            }
            task.resume()
        }
    }
    
    private func adjustImageSize(_ image: UIImage) {
        let imageAspectRatio = image.size.width / image.size.height
        let viewAspectRatio = imageView.frame.size.width / imageView.frame.size.height
        
        if imageAspectRatio > viewAspectRatio {
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.contentMode = .scaleAspectFit
        }
    }
}
