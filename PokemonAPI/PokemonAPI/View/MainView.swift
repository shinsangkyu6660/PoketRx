//
//  MainView.swift
//  PokemonAPI
//
//  Created by 신상규 on 8/7/24.
//

import UIKit
import SnapKit
import RxSwift

class MainView: UIViewController {

    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    var pokemons: [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainRed
        setupLayout()
        bindViewModel()
        viewModel.fetchPokemonList(limit: 21, offset: 0)
    }
    
    private lazy var poketmoncollectionView: UICollectionView = {
        // 콜랙션뷰의 레이아웃
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 116, height: 116)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        // 콜랙션뷰 생성
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(PoketmonCell.self, forCellWithReuseIdentifier: PoketmonCell.id)
        return collectionView
    }()
    
    // 상단 포켓몬볼
    private let poketmonImage: UIImageView = {
        let poketmonImage = UIImageView()
        poketmonImage.layer.cornerRadius = 60
        poketmonImage.image = UIImage(named: "pokemonBall")
        poketmonImage.layer.borderColor = UIColor.gray.cgColor
        poketmonImage.layer.borderWidth = 5
        poketmonImage.clipsToBounds = true
        return poketmonImage
    }()
    
    // 포켓몬볼과 콜랙션뷰 레이아웃
    private func setupLayout() {
        [poketmonImage, poketmoncollectionView].forEach { view.addSubview($0) }
        
        poketmonImage.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(120)
        }
        
        poketmoncollectionView.snp.makeConstraints {
            $0.top.equalTo(poketmonImage.snp.bottom).offset(20)
            $0.left.right.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func bindViewModel() {
        // ViewModel의 pokemons BehaviorSubject를 구독함
        viewModel.pokemons
        // poketmoncollectionView의 데이터 소스를 바인딩
            .bind(to: poketmoncollectionView.rx.items(cellIdentifier: PoketmonCell.id, cellType: PoketmonCell.self)) { (row, pokemon, cell) in
                // 각 셀에 대해, ViewModel에서 가져온 pokemon 객체로 셀을 구성
                cell.configure(with: pokemon)
                // DisposeBag을 통해 메모리 관리
            }.disposed(by: disposeBag)
        
        // UICollectionView의 모델이 선택되었을 때
        poketmoncollectionView.rx.modelSelected(Pokemon.self)
            .subscribe(onNext: { [weak self] pokemon in
                // 선택된 Pokemon 객체를 detailVC에 설정
                let detailVC = PokemonService()
                detailVC.pokemon = pokemon
                
                // 내비게이션 컨트롤러를 통해 detailVC를 푸시하여 화면 전환
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }).disposed(by: disposeBag)
    }
}

extension UIColor {
    static let mainRed = UIColor(red: 190/255, green: 30/255, blue: 40/255, alpha: 1.0)
    static let darkRed = UIColor(red: 120/255, green: 30/255, blue: 30/255, alpha: 1.0)
    static let cellBackground = UIColor(red: 245/255, green: 245/255, blue: 235/255, alpha: 1.0)
}
