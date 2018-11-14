//
//  String.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

extension String {

    func limit(to: Int, numberOfPeriods: Int = 3) -> String {
        if self.count >= to {
            return self.prefix(to) + String(repeating: ".", count: numberOfPeriods)
        }
        return self
    }
}
