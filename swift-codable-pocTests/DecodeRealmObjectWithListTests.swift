//
//  DecodeRealmObjectWithListTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/21/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
import RealmSwift
@testable import swift_codable_poc

// Decoding realm objects seems to be fine. If object has List propety, it should
// be decoded manally because List type is not Decodable. See example below.
class DecodeRealmObjectWithListTests: XCTestCase {
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
  
  let decoder = JSONDecoder()
  
  func test() {
    let policy = try! decoder.decode(RealmPolicy.self, from: jsonPolicy)
    XCTAssertEqual(policy.rules.count, 3)
    dump(policy)
  }
}

class RealmPolicyRule: Object, Decodable {
  @objc dynamic var id = ""
  @objc dynamic var code = ""
}

class RealmPolicy: Object, Decodable {
  @objc dynamic var name = ""
  var rules = List<RealmPolicyRule>()

  private enum CodingKeys: String, CodingKey {
    case name, rules
  }
  
  required convenience public init(from decoder: Decoder) throws {
    self.init()
    let map = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try map.decode(.name)
    let rulesDict = try map.decode([String: RealmPolicyRule].self, forKey: .rules)
    self.rules.append(objectsIn: rulesDict.values)
  }
}
