//
//  File.swift
//  PokemonAPI
//
//  Created by 신상규 on 8/7/24.
//

import UIKit
import SnapKit

class PokemonService: UIViewController {
    
    var pokemon: Pokemon?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainRed
        setupLayout()
        configureView()
    }
    
    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(infoLabel)
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(300)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(20)
        }
    }
    
    private func configureView() {
        // pokemon 객체가 nil이 아닌 경우, 즉 데이터가 올바르게 설정된 경우에만 실행됩니다.
        if let pokemon = pokemon {
            // 네비게이션 바의 제목을 포켓몬 이름의 첫 글자를 대문자로 설정합니다.
            title = pokemon.name.capitalized
            
            // 포켓몬의 정보를 포함한 문자열을 infoLabel에 설정합니다.
            infoLabel.text = """
                No.\(pokemon.id) \(pokemon.name.capitalized)
                타입: \(pokemon.types.map { $0.type.name }.joined(separator: ", "))
                키: \(pokemon.height / 10)m
                몸무게: \(pokemon.weight / 10)kg
                """
            
            // 포켓몬의 이미지 URL을 생성합니다.
            if let imageUrl = URL(string: pokemon.sprites.frontDefault ?? "") {
                // URLSession을 사용하여 비동기적으로 이미지를 다운로드합니다.
                let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    // 데이터가 존재하고, UIImage로 변환할 수 있는 경우
                    if let data = data, let image = UIImage(data: data) {
                        // 메인 스레드에서 UI 업데이트를 수행합니다.
                        DispatchQueue.main.async {
                            // imageView에 다운로드한 이미지를 설정합니다.
                            self.imageView.image = image
                            // 이미지 크기에 따라 imageView의 컨텐츠 모드를 조정합니다.
                            self.adjustImageSize(image)
                        }
                    }
                }
                // 다운로드 작업을 시작합니다.
                task.resume()
            }
        }
    }
    
    private func adjustImageSize(_ image: UIImage) {
        // 이미지의 가로 세로 비율을 계산합니다.
        let imageAspectRatio = image.size.width / image.size.height
        // imageView의 가로 세로 비율을 계산합니다.
        let viewAspectRatio = imageView.frame.size.width / imageView.frame.size.height
        
        // 이미지의 비율이 imageView의 비율보다 크면, 이미지가 view보다 넓거나 좁은 경우입니다.
        if imageAspectRatio > viewAspectRatio {
            // 이미지가 imageView를 넘칠 경우, 비율을 유지하며 이미지가 잘리지 않도록 .scaleAspectFill로 설정합니다.
            imageView.contentMode = .scaleAspectFill
        } else {
            // 이미지가 imageView보다 작을 경우, 이미지가 전체를 채우도록 .scaleAspectFit으로 설정합니다.
            imageView.contentMode = .scaleAspectFit
        }
    }
}
