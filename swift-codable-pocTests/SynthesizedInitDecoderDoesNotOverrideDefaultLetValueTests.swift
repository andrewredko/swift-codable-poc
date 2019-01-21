//
//  SynthesizedInitDecoderDoesNotOverrideDefaultLetValueTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/20/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_codable_poc

// We should just bear in mind that compiler does not give a warning when
// init(from decoder:) method is synthesized and class/struct has constant with detualt value.
// In that case, there is no warning from compiler that default value
// will not be overridden by decoder, as some may expect.
// per https://forums.swift.org/t/revisit-synthesized-init-from-decoder-for-structs-with-default-property-values/12296/2
class SynthesizedInitDecoderDoesNotOverrideDefaultLetValueTests: XCTestCase {
  
  class ConstantName: Decodable {
    let name: String = "<unknown>"
  }
  
  class VariableName: Decodable {
    var name: String = "<unknown>"
  }
  
  let decoder = JSONDecoder()
  
  let json = """
{
  "name": "Bob"
}
""".data(using: .utf8)!
  
  func testConstantNameNotOverride() {
    let user = try! decoder.decode(ConstantName.self, from: json)
    XCTAssertEqual(user.name, "<unknown>")
  }
  
  func testVariableNameDoesOverride() {
    let user = try! decoder.decode(VariableName.self, from: json)
    XCTAssertEqual(user.name, "Bob")
  }
}
