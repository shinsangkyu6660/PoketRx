//
//  Model.swift
//  PokemonAPI
//
//  Created by 신상규 on 8/7/24.
//

import Foundation

import Foundation

struct PokemonResponse: Codable {
    let count: Int
    let next: String?
    let results: [PokemonResult]
}

struct PokemonResult: Codable {
    let name: String
    let url: String
}

struct Pokemon: Codable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let height: Int
    let weight: Int
    let sprites: Sprites
}

struct PokemonType: Codable {
    let slot: Int
    let type: TypeName
}

struct TypeName: Codable {
    let name: String
}

struct Sprites: Codable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
