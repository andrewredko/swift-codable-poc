//
//  OmitExplicitDecodingAtLevel2Tests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/20/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_codable_poc

// We can override decode behavior on different levels of nested information,
// while still having implicit decoding on other levels. See below that all
// levels of information is decoded fine.
class OmitExplicitDecodingAtLevel2Tests: XCTestCase {
  
  class Organization: Decodable {
    var name: String = ""
    var departments = [Department]()
    
    private enum CodingKeys: String, CodingKey {
      case name = "orgName"
      case departments
    }
    
    required init(from decoder: Decoder) throws {
      let map = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try map.decodeIfPresent(.name) ?? ""
      self.departments = (try? map.decode(.departments)) ?? [Department]()
    }
  }
  
  class Department: Decodable {
    var name: String = ""
    var employees = [Employee]()
  }
  
  class Employee: Decodable {
    var firstName: String? = nil
    var lastName: String = ""
    
    private enum CodingKeys: String, CodingKey {
      case firstName = "name"
      case lastName = "surname"
    }
    
    required init(from decoder: Decoder) throws {
      let map = try decoder.container(keyedBy: CodingKeys.self)
      self.firstName = try map.decodeIfPresent(.firstName)
      self.lastName = (try? map.decode(.lastName)) ?? "<unknown>"
    }
  }

  let decoder = JSONDecoder()
  
  let json = """
{
  "orgName": "Some Org",
  "departments": [
    {
      "name": "Sales",
      "employees": [
        {
          "name": "John",
          "surname": "Doe"
        }
      ]
    }
  ]
}
""".data(using: .utf8)!
  
  func test() {
    let org = try! decoder.decode(Organization.self, from: json)
    XCTAssertEqual(org.name, "Some Org")
    XCTAssertEqual(org.departments[0].name, "Sales")
    XCTAssertEqual(org.departments[0].employees[0].firstName, "John")
  }
}
