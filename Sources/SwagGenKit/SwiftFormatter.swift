//
//  SwiftCodegen.swift
//  SwagGen
//
//  Created by Yonas Kolb on 3/12/2016.
//  Copyright © 2016 Yonas Kolb. All rights reserved.
//

import Foundation
import Swagger

public class SwiftFormatter: CodeFormatter {

    var disallowedKeywords: [String] {
        return [
            "Type",
            "class",
            "struct",
            "enum",
            "protocol",
            "extension",
            "return",
            "throw",
            "throws",
            "rethrows",
            "public",
            "open",
            "private",
            "fileprivate",
            "internal",
            "let",
            "var",
            "where",
            "guard",
            "associatedtype",
            "deinit",
            "func",
            "import",
            "inout",
            "operator",
            "static",
            "subscript",
            "typealias",
            "case",
            "break",
            "continue",
            "default",
            "defer",
            "do",
            "else",
            "fallthrough",
            "for",
            "if",
            "in",
            "repeat",
            "switch",
            "where",
            "while",
            "as",
            "Any",
            "AnyObject",
            "catch",
            "false",
            "true",
            "is",
            "nil",
            "super",
            "self",
            "Self",
        ]
    }

    var inbuiltTypes: [String] = [
        "Error",
        "Data",
    ]

    override var disallowedNames: [String] { return disallowedKeywords + inbuiltTypes }
    override var disallowedTypes: [String] { return disallowedKeywords + inbuiltTypes }

    override func getValueType(_ value: Value) -> String {

        if value.enumValues != nil && value.name != "" {
            return getEnumName(value)
        }

        if let format = value.format {
            switch format.lowercased() {
            case "date-time": return "Date"
            default: break
            }
        }

        if let type = value.type {

            switch type.lowercased() {
            case "int", "integer", "int32", "int64": return "Int"
            case "string":
                if value.format == "uri" {
                    return "URL"
                }
                return "String"
            case "number", "double": return "Double"
            case "date": return "Date"
            case "boolean": return "Bool"
            case "file": return "URL"
            case "uri": return "URL"
            case "object":
                if let schema = value.dictionarySchema {
                    return "[String: \(getSchemaType(schema))]"
                } else if let dictionaryValue = value.dictionaryValue {
                    return "[String: \(dictionaryValue.enumValues != nil ? getEnumName(value) : getValueType(dictionaryValue))]"
                } else {
                    return "[String: Any]"
                }
            case "array":
                if let schema = value.arraySchema {
                    return "[\(getSchemaType(schema))]"
                } else if let arrayValue = value.arrayValue {
                    return "[\(arrayValue.enumValues != nil ? getEnumName(value) : getValueType(arrayValue))]"
                }
            default: break
            }
        }
        return super.getValueType(value)
    }

    override func getValueContext(value: Value) -> [String: Any?] {
        var encodedValue = getValueName(value)

        let type = getValueType(value)
        let jsonTypes = ["Any", "[String: Any]", "Int", "String", "Float", "Double", "Bool"]

        if !jsonTypes.contains(type) && !jsonTypes.map({"[\($0)]"}).contains(type) && !jsonTypes.map({"[String: \($0)]"}).contains(type) {
            encodedValue += ".encode()"
        }

        if value.type == "array", let collectionFormatSeperator = value.collectionFormatSeperator {
            if type != "[String]" {
                encodedValue += ".map({ \"\\($0)\" })"
            }
            encodedValue += ".joined(separator: \"\(collectionFormatSeperator)\")"
        }

        if !value.required, let range = encodedValue.range(of: ".") {
            encodedValue = encodedValue.replacingOccurrences(of: ".", with: "?.", options: [], range: range)
        }
        return super.getValueContext(value: value) + [
            "encodedValue": encodedValue,
            "optionalType": getValueType(value) + (value.required ? "" : "?"),
        ]
    }

    override func getSchemaContext(schema: Schema) -> [String : Any?] {
        var context = super.getSchemaContext(schema: schema)

        switch schema.additionalProperties {
        case .a(let value): context["additionalPropertiesType"] = getValueType(value)
        case .b(let additionalProperties):
            if additionalProperties {
                context["additionalPropertiesType"] = "Any"
            }
        }
        return context
    }

    override func getEscapedType(_ name: String) -> String {
        if inbuiltTypes.contains(name) {
            return "\(name)Type"
        }
        return "`\(name)`"
    }

    override func getEscapedName(_ name: String) -> String {
        return "`\(name)`"
    }

    override func getEnumCaseName(_ name: String) -> String {
        return super.getEnumCaseName(name).lowerCamelCased()
    }
}
