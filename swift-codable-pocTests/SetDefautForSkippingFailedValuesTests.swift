//
//  SetDefautForSkippingFailedValuesTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/20/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_codable_poc

// We cannot retain default values with synthesized decoding, if json does
// not contain corresponding keys. We need to override decode behavior and
// have some boilerplate code for this case.
class SetDefautForSkippingFailedValuesTests: XCTestCase {
  
  enum System: String, Decodable {
    case ios, macos, tvos, watchos, unknown
  }
  
  class Container: Decodable {
    let systemOptional: System?
    var systemCheckValue: System = .unknown
    var systemIgnoreValue: System = .unknown
    
    required init(from decoder: Decoder) throws {
      let map = try decoder.container(keyedBy: CodingKeys.self)
      self.systemOptional = try map.decodeIfPresent(.systemOptional)
      self.systemIgnoreValue = (try? map.decode(.systemIgnoreValue)) ?? .unknown
      // Downside: need to duplicate default value here
      self.systemCheckValue = try map.decodeIfPresent(.systemCheckValue) ?? .unknown
      // Or, can doing this, but it will be even more boilerplate code.
      // if let systemCheckValue = try map.decodeIfPresent(System.self, forKey: .systemCheckValue) {
      //   self.systemCheckValue = systemCheckValue
      // }
    }
    
    private enum CodingKeys: CodingKey {
      case systemOptional
      case systemCheckValue
      case systemIgnoreValue
    }
  }
  
  let json = """
{
    "systemIgnoreValue": "caros"
}
""".data(using: .utf8)!
  
  let jsonWrongVaue = """
{
    "systemCheckValue": "caros"
    "systemIgnoreValue": "caros"
}
""".data(using: .utf8)!
  
  func test() throws {
    let device = try JSONDecoder().decode(Container.self, from: json)
    XCTAssertEqual(device.systemOptional, nil)
    XCTAssertEqual(device.systemCheckValue, .unknown)
    XCTAssertEqual(device.systemIgnoreValue, .unknown)
  }
  
  func testWrongValue() throws {
    do {
      _ = try JSONDecoder().decode(Container.self, from: jsonWrongVaue)
      XCTFail("Must not get here")
    } catch {
      XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it isn’t in the correct format.")
    }
  }
}
