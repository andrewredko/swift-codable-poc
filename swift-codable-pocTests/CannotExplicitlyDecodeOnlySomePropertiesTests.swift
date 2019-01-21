//
//  CannotExplicitlyDecodeOnlySomePropertiesTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/20/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_codable_poc

// We cannot override synthesized decode behavior for only some properties.
// If we need to override at least one, then we must override all. See below
// that `firstName` value is not decoded.
class CannotCustomlyDecodeOnlySomePropertiesTests: XCTestCase {
  
  class User: Decodable {
    var firstName: String? = nil
    var lastName: String = ""
    
    private enum CodingKeys: String, CodingKey {
      case firstName, lastName
    }
    
    required init(from decoder: Decoder) throws {
      let map = try decoder.container(keyedBy: CodingKeys.self)
      self.lastName = (try? map.decode(.lastName)) ?? "<unknown>"
    }
  }
  
  let decoder = JSONDecoder()
  
  let json = """
{
  "firstName": "John",
  "lastName": "Doe"
}
""".data(using: .utf8)!
 
  func test() {
    let user = try! decoder.decode(User.self, from: json)
    XCTAssertEqual(user.firstName, nil)
    XCTAssertEqual(user.lastName, "Doe")
  }
}
