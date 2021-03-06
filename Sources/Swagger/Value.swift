//
//  Value.swift
//  SwagGen
//
//  Created by Yonas Kolb on 18/2/17.
//
//

import Foundation
import JSONUtilities

public class Value: JSONObjectConvertible {

    public var name: String
    public let description: String?
    public var required: Bool
    public var type: String?
    public var reference: String?
    public var format: String?
    public var enumValues: [String]?
    public var arrayValue: Value?
    public var arraySchema: Schema?
    var arrayRef: String?
    public var schema: Schema?
    public var dictionarySchema: Schema?
    var dictionarySchemaRef: String?
    public var dictionaryValue: Value?
    public var collectionFormat: String?
    public var collectionFormatSeperator: String? {
        guard let collectionFormat = collectionFormat?.lowercased() else { return nil }
        switch collectionFormat {
        case "csv": return ","
        case "ssv": return " "
        case "tsv": return "\t"
        case "pipes": return "|"
        default: return nil
        }
    }
    public var isGlobal = false
    public var globalName: String?
    public let json: JSONDictionary

    required public init(jsonDictionary: JSONDictionary) throws {
        json = jsonDictionary
        name = jsonDictionary.json(atKeyPath: "name") ?? ""
        description = jsonDictionary.json(atKeyPath: "description")
        collectionFormat = jsonDictionary.json(atKeyPath: "collectionFormat")

        reference = jsonDictionary.json(atKeyPath: "$ref")

        arrayRef = jsonDictionary.json(atKeyPath: "items.$ref")
        arrayValue = jsonDictionary.json(atKeyPath: "items")

        dictionarySchemaRef = jsonDictionary.json(atKeyPath: "additionalProperties.$ref")
        dictionaryValue = jsonDictionary.json(atKeyPath: "additionalProperties")

        if let value = dictionaryValue, value.name.isEmpty {
            value.name = name
        }

        if let value = arrayValue, value.name.isEmpty {
            value.name = name
        }

        required = jsonDictionary.json(atKeyPath: "required") ?? false
        type = jsonDictionary.json(atKeyPath: "type")
        format = jsonDictionary.json(atKeyPath: "format")
        enumValues = jsonDictionary.json(atKeyPath: "enum")
        if let schemaRef = jsonDictionary.json(atKeyPath: "schema.$ref") as String? {
            reference = schemaRef
        }
        else if let schema = jsonDictionary.json(atKeyPath: "schema") as Schema? {
            self.schema = schema
            self.schema?.name = name
            if schema.type == "object" {
                self.schema?.anonymous = true
            }
        }

        if let ref = jsonDictionary.json(atKeyPath: "schema.items.$ref") as String? {
            arrayRef = ref
            if let type = jsonDictionary.json(atKeyPath: "schema.type") as String? {
                self.type = type
            }
        }
    }

    var isEnum: Bool {
        return enumValues != nil || arrayValue?.isEnum == true || dictionaryValue?.isEnum == true
    }

    public var nestedEnumValues: [String]? {
        return enumValues ?? arrayValue?.nestedEnumValues ?? dictionaryValue?.nestedEnumValues
    }

    func deepDescription(prefix: String) -> String {
        return "\(prefix)\(name): \(type ?? "")"
    }
}
