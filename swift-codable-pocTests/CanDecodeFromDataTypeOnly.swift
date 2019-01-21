//
//  UpdateExistingObjectFromDataTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/20/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_codable_poc

// Native JSONDecoder can decode from Data type only. If there is a need to
// decode from Array or Dictionary type, there are some workarounds that seem
// to support that. Like https://github.com/norio-nomura/ObjectEncoder or
// https://stackoverflow.com/questions/44603248/how-to-decode-a-property-with-type-of-json-dictionary-in-swift-4-decodable-proto
class UpdateExistingObjectFromDataTests: XCTestCase {
  
  class User: Decodable {
    var firstName: String
    var lastName: String
  }
  
  let jsonString = """
{
  "firstName": "John",
  "lastName": "Doe"
}
"""
  
  func test() {
    guard let dictionary = jsonDictionary(),
      let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
        XCTFail("Cannot convert dictionary to data"); return
    }
    let user = try! JSONDecoder().decode(User.self, from: jsonData)
    XCTAssertEqual(user.firstName, "John")
    XCTAssertEqual(user.lastName, "Doe")
  }
  
  func jsonDictionary() -> [String: Any]? {
    if let data = jsonString.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
}
