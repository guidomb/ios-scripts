//
//  Greeter.swift
//  iOSScriptsCarthage
//
//  Created by Guido Marucci Blas on 9/17/15.
//  Copyright (c) 2015 guidomb. All rights reserved.
//

import Foundation

public struct Greeter {
    
    let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func greet() -> String {
        return "Hello \(name)"
    }
    
}