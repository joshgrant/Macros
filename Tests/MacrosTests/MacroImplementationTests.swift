//
//  MacroImplementationTests.swift
//  
//
//  Created by Me on 4/24/24.
//

import XCTest
import Macros

@EasyInit
struct SUT {
    var id: UUID
    var name: String?
    var closure: () -> Void
}

final class MacroImplementationTests: XCTestCase {

    func test_sutInit() throws {
        let sut = SUT(id: .init(), name: "Hi", closure: {})
        let newSut = SUT(sut, name: "sup")
        XCTAssertEqual(sut.name, "Hi")
        XCTAssertEqual(newSut.name, "sup")
    }
}
