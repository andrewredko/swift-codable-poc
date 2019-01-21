//
//  KeyedDecodingContainer+Helpers.swift
//  swift-codable-poc
//
//  Created by Andrey Redko on 1/19/19.
//  Copyright © 2019 Travelbank. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T {
    return try self.decode(T.self, forKey: key)
  }
  
  public func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
    return try decodeIfPresent(T.self, forKey: key)
  }
}
