//
//  Image.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

struct Image: Decodable {
    let scalable: Bool
    let width: Int
    let height: Int
    let type: String
    let url: String
}
