//
//  iOSScriptsCarthageTests.swift
//  iOSScriptsCarthage
//
//  Created by Guido Marucci Blas on 9/17/15.
//  Copyright (c) 2015 guidomb. All rights reserved.
//

import Foundation
import Quick
import Nimble
import iOSScriptsCarthage

class GreeterSpec: QuickSpec {
    
    override func spec() {
    
        var greeter: Greeter!
        
        beforeEach {
            greeter = Greeter(name: "Guido Marucci Blas")
        }
        
        describe("#greet") {
            
            it("greets the given name") {
                expect(greeter.greet()).to(equal("Hello Guido Marucci Blas"))
            }
            
        }
        
    }
    
}