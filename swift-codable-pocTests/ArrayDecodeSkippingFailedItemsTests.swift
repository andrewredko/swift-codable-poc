//
//  ArrayDecodeSkippingFailedItemsTests.swift
//  swift-codable-pocTests
//
//  Created by Andrey Redko on 1/19/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation
import XCTest

// Decoding an array fails if single element decoding fails. Here is a
// suggested workaround for this, with using `FailableCodableArray` which
// skips failed elemets.
//per https://stackoverflow.com/a/46369152
//and https://bugs.swift.org/browse/SR-5953
class ArrayDecodeSkippingFailedItemsTests: XCTestCase {

  struct FailableDecodable<Base: Decodable>: Decodable {
    let base: Base?
    
    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.base = try? container.decode(Base.self)
    }
  }
  
  struct FailableCodableArray<Element : Codable> : Codable {
    var elements: [Element]
    
    init(from decoder: Decoder) throws {
      var container = try decoder.unkeyedContainer()
      var elements = [Element]()
      
      if let count = container.count {
        elements.reserveCapacity(count)
      }
      
      while !container.isAtEnd {
        if let element = try container
          .decode(FailableDecodable<Element>.self).base {
          elements.append(element)
        }
      }
      self.elements = elements
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(elements)
    }
  }
  
  struct Product: Codable {
    var name: String
    var points: Int
    var description: String?
  }
  
  struct Store: Codable {
    var products: [Product]
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.products = try container
        .decode(FailableCodableArray<Product>.self, forKey: .products)
        .elements
    }
  }
  
  // or...
  struct Store2: Codable {
    private let _products: FailableCodableArray<Product>
    var products: [Product] {
      return _products.elements
    }
    
    private enum CodingKeys : String, CodingKey {
      case _products = "products"
    }
  }

  let productsJson = """
[
    {
        "name": "Banana",
        "points": 200,
        "description": "A banana grown in Ecuador."
    },
    {
        "name": "Orange"
    }
]
""".data(using: .utf8)!

  private let storeJson = """
{
  "products":
  [
    {
      "name": "Banana",
      "points": 200,
      "description": "A banana grown in Ecuador."
    },
    {
      "name": "Orange"
    }
  ]
}
""".data(using: .utf8)!


  func testDecodeArray() throws {
    let products = try JSONDecoder()
      .decode(FailableCodableArray<Product>.self, from: productsJson)
      .elements
    XCTAssertEqual(products.count, 1)
  }
  
  func testDecodeObjectContainingArray1() throws {
    let store = try JSONDecoder().decode(Store.self, from: storeJson)
    XCTAssertEqual(store.products.count, 1)
  }

  func testDecodeObjectContainingArray2() throws {
    let store2 = try JSONDecoder().decode(Store2.self, from: storeJson)
    XCTAssertEqual(store2.products.count, 1)
  }
}
