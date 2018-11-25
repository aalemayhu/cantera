//
//  DebugHandler.swift
//  cantera
//
//  Created by Alexander Alemayhu on 25/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

class DebugHandler {
    // Note: would be awesome if there was some toggle here to generate gifvs via simulator
    static func print_string(_ msg: String) {
        #if DEBUG
        print("DEBUG: \(msg)")
        #endif
    }
}
