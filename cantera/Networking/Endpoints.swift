//
//  Endpoints.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

private let baseImageURL = URL(string: "https://images.finncdn.no/dynamic/480x360c/")

enum Endpoints {
    case json
    case image(String)

    func url() -> URL? {
        switch self {
        case .json:
            return URL(string: "https://gist.githubusercontent.com/3lvis/3799feea005ed49942dcb56386ecec2b/raw/63249144485884d279d55f4f3907e37098f55c74/discover.json")
        case .image(let id):
            return baseImageURL?.appendingPathComponent(id)
        }
    }
}
