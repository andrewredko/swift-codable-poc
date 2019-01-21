//
//  DecodeDictionaryWithEnumKeysTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/21/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_codable_poc

// Out-of-box we can only decode dictionaries with keys of either String or Int type.
// https://forums.swift.org/t/json-encoding-decoding-weird-encoding-of-dictionary-with-enum-values
// There is a workaround for case when need to decode dictionary with enum key type.
// https://stackoverflow.com/questions/44725202/swift-4-decodable-dictionary-with-enum-as-key?rq=1
// The downsides, at least:
// 1. It requires some work to be done in init(from:).
// 2. Apart from CodableDictionary, we should add simular DecodableDictionary for
// types that implement Decodable only. Hense CodableDictionary can only be used with
// Codable types. See compiler error, if you try to change PolicyRyle to implement
// Decodable instead of Codable.
// 3. Seems like it is not possible to decode json that with dictionary at the root level using this approach. Still can be done in other way - see `PassingDataToChildDecoderTests`.

struct CodableDictionary<Key: Hashable, Value: Codable>: Codable where Key : CodingKey {
  let decoded: [Key: Value]
  
  init(_ decoded: [Key: Value]) {
    self.decoded = decoded
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    
    decoded = Dictionary(uniqueKeysWithValues:
      try container.allKeys.lazy.map {
        (key: $0, value: try container.decode(Value.self, forKey: $0))
      }
    )
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    
    for (key, value) in decoded {
      try container.encode(value, forKey: key)
    }
  }
}

class DecodeDictionaryWithEnumKeysTests: XCTestCase {
  let jsonRules = """
{
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
  
  enum PolicyRuleType: String, CodingKey {
    case daysInAdvance = "daysInAdvance"
    case overBudget = "overBudget"
    case always = "always"
    case other = "other"
  }
  
  class PolicyRule: Codable {
    let id: String
    let code: String
  }
  
  class Policy: Codable {
    let rules: [PolicyRuleType: PolicyRule]
    
    private enum CodingKeys: CodingKey {
      case rules
    }
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.rules = try container.decode(CodableDictionary.self, forKey: .rules).decoded
    }
    
    func encode(to encoder: Encoder) throws {
      fatalError("TBD")
    }
  }
  
  let decoder = JSONDecoder()
  
  func test() {
    let policy = try! decoder.decode(Policy.self, from: jsonRules)
    XCTAssertEqual(policy.rules.count, 3)
  }
}
