//
//  ViewController.swift
//  PokemonAPI
//
//  Created by 신상규 on 8/7/24.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    private let disposeBag = DisposeBag()
    
    // 포켓몬 목록을 담는 BehaviorRelay (RxCocoa의 타입)
    // 초기값은 빈 배열입니다.
    let pokemons = BehaviorRelay<[Pokemon]>(value: [])
    
    // 포켓몬 목록을 서버에서 가져오는 함수
    func fetchPokemonList(limit: Int, offset: Int) {
        // API 요청 URL 생성
        let urlString = "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }
        
        // URLSession을 사용하여 비동기적으로 HTTP 요청을 보냅니다.
        URLSession.shared.rx.response(request: URLRequest(url: url))
            // 서버 응답과 데이터 처리
            .map { response, data -> PokemonResponse? in
                // 응답 상태 코드가 200~299 범위에 있는지 확인합니다.
                // 상태 코드가 이 범위에 있으면 JSON 데이터로 변환하여 반환합니다.
                guard 200..<300 ~= response.statusCode else { return nil }
                return try? JSONDecoder().decode(PokemonResponse.self, from: data)
            }
            // nil을 제거하고 유효한 PokemonResponse 객체만 반환합니다.
            .compactMap { $0 }
            // 응답을 처리하여 포켓몬 상세 정보를 가져옵니다.
            .subscribe(onNext: { [weak self] response in
                // 응답에서 포켓몬 목록을 가져와 상세 정보를 요청합니다.
                self?.fetchPokemonDetails(pokemonResults: response.results)
            })
            // DisposeBag을 통해 메모리 관리
            .disposed(by: disposeBag)
    }
    
    // 포켓몬 상세 정보를 서버에서 가져오는 함수
    private func fetchPokemonDetails(pokemonResults: [PokemonResult]) {
        // 포켓몬 결과 배열을 Observable로 변환합니다.
        Observable.from(pokemonResults)
            // 각 포켓몬 결과에 대해 상세 정보를 비동기적으로 가져옵니다.
            .flatMap { result -> Observable<Pokemon?> in
                // 포켓몬 상세 정보 URL을 생성합니다.
                guard let url = URL(string: result.url) else { return .just(nil) }
                return URLSession.shared.rx.response(request: URLRequest(url: url))
                    // 응답과 데이터를 처리하여 포켓몬 객체로 변환합니다.
                    .map { response, data -> Pokemon? in
                        // 응답 상태 코드가 200~299 범위에 있는지 확인합니다.
                        guard 200..<300 ~= response.statusCode else { return nil }
                        return try? JSONDecoder().decode(Pokemon.self, from: data)
                    }
            }
            // nil 값을 제거하고 유효한 포켓몬 객체만 반환합니다.
            .compactMap { $0 }
            // 모든 포켓몬 객체를 배열로 변환합니다.
            .toArray()
            // 포켓몬 배열을 BehaviorRelay에 전달하여 UI를 업데이트합니다.
            .subscribe(onSuccess: { [weak self] pokemons in
                self?.pokemons.accept(pokemons)
            }).disposed(by: disposeBag)            
    }
}
