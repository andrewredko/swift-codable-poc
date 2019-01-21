//
//  DecodeDictionaryTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/20/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_codable_poc

// It is not a chalange to decode dictionaries, and works as expected per Apple
// docs. Here, I just wanted to demonstrate it.
class DecodeDictionaryTests: XCTestCase {
  let jsonRules = """
{
  "always": {
    "id": "1",
    "code": "ALWAYS"
  },
  "daysInAdvance": {
    "id": "2",
    "code": "DAYS_IN_ADVANCE"
  },
  "overBudget": {
    "id": "3",
    "code": "OVER_BUDGET"
  }
}
""".data(using: .utf8)!
  
  
  let jsonPolicy = """
{
  "name": "Bla-Bla Policy",
  "rules": {
    "always": {
      "id": "1",
      "code": "ALWAYS"
    },
    "daysInAdvance": {
      "id": "2",
      "code": "DAYS_IN_ADVANCE"
    },
    "overBudget": {
      "id": "3",
      "code": "OVER_BUDGET"
    }
  }
}
""".data(using: .utf8)!
  
  class PolicyRuleDecodable: Decodable {
    let id: String
    let code: String
  }
  
  class Policy: Decodable {
    let name: String
    let rules: [String:PolicyRuleDecodable]
  }
  
  let decoder = JSONDecoder()
  
  func testDecodePolicyWithRules() {
    let policy = try! decoder.decode(Policy.self, from: jsonPolicy)
    XCTAssertEqual(policy.rules.count, 3)
  }
  
  func testDecodeRulesAlone() {
    let dict = try! decoder.decode([String:PolicyRuleDecodable].self, from: jsonRules)
    XCTAssertEqual(dict.count, 3)
  }
}
