//
//  NestableCodingKey.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//


import Foundation

@propertyWrapper
struct NestedKey<T: Decodable>: Decodable {
    var wrappedValue: T
    struct AnyCodingKey: CodingKey {
        let stringValue: String
        let intValue: Int?
        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    init(from decoder: Decoder) throws {
        let key = decoder.codingPath.last!
        guard let nestedKey = key as? NestableCodingKey else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Key \(key) is not a NestableCodingKey"))
        }
        let nextKeys = nestedKey.path.dropFirst()

        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        let lastLeaf = try nextKeys.indices.dropLast().reduce(container) { (nestedContainer, keyIdx) in
            do {
                return try nestedContainer.nestedContainer(keyedBy: AnyCodingKey.self, forKey: AnyCodingKey(stringValue: nextKeys[keyIdx]))
            } catch DecodingError.keyNotFound(let key, let ctx) {
                try NestedKey.keyNotFound(key: key, ctx: ctx, container: container, nextKeys: nextKeys[..<keyIdx])
            }
        }

        do {
            self.wrappedValue = try lastLeaf.decode(T.self, forKey: AnyCodingKey(stringValue: nextKeys.last!))
        } catch DecodingError.keyNotFound(let key, let ctx) {
            try NestedKey.keyNotFound(key: key, ctx: ctx, container: container, nextKeys: nextKeys.dropLast())
        }
    }

    private static func keyNotFound<C: Collection>(
        key: CodingKey, ctx: DecodingError.Context,
        container: KeyedDecodingContainer<AnyCodingKey>, nextKeys: C) throws -> Never
        where C.Element == String
    {
        throw DecodingError.keyNotFound(key, DecodingError.Context(
            codingPath: container.codingPath + nextKeys.map(AnyCodingKey.init(stringValue:)),
            debugDescription: "NestedKey: No value associated with key \"\(key.stringValue)\"",
            underlyingError: ctx.underlyingError
        ))
    }
}

protocol NestableCodingKey: CodingKey {
    var path: [String] { get }
}

extension NestableCodingKey where Self: RawRepresentable, Self.RawValue == String {
    init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    var stringValue: String {
        path.first!
    }

    init?(intValue: Int) {
        fatalError()
    }
    var intValue: Int? { nil }

    var path: [String] {
        self.rawValue.components(separatedBy: "/")
    }
}
