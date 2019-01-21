//
//  PassingDataToChildDecoderTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/20/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_codable_poc

// When there is a need to pass some data from parent to child object,
// we can do it with overriding init(from:). Here is an example.
// Also, here it demostrates the case when JSON has dirrefent
// structure than out PolicyRule type. To handle it, we use additional
// PolicyRuleDecodable.
class PassingDataToChildDecoderTests: XCTestCase {
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
  
  enum PolicyRuleType: String, Decodable {
    case daysInAdvance = "daysInAdvance"
    case overBudget = "overBudget"
    case always = "always"
    case other = "other"
  }
  
  class PolicyRule {
    private(set) var id = ""
    private(set) var code = ""
    private(set) var type = PolicyRuleType.other
    
    init(rule: PolicyRuleDecodable, type: PolicyRuleType) {
      self.id = rule.id
      self.code = rule.code
      self.type = type
    }
    
    convenience init?(rule: PolicyRuleDecodable, type: String) {
      guard let t = PolicyRuleType(rawValue: type) else { return nil }
      self.init(rule: rule, type: t)
    }
  }
  
  class PolicyRuleDecodable: Decodable {
    let id: String
    let code: String
  }
  
  class Policy: Decodable {
    let name: String
    let rules: [PolicyRule]
    
    private enum CodingKeys: String, CodingKey {
      case name, rules
    }
    
    required init(from decoder: Decoder) throws {
      let map = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try map.decode(.name)
      let rules = try map.decode([String: PolicyRuleDecodable].self, forKey: .rules)
      self.rules = rules.compactMap { PolicyRule(rule: $0.value, type: $0.key) }
    }
  }
  
  let decoder = JSONDecoder()
  
  func test() {
    let policy = try! decoder.decode(Policy.self, from: jsonPolicy)
    XCTAssertEqual(policy.rules.count, 3)
  }
}
