//
//  DataElement.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 11/15/24.
//

import Foundation

/// Represents a data element that is part of a ISO-8583.
struct DataElement {
    
    /// The data element name.
    var name: String
    /// The data element value.
    var value: String
    /// The data element data type.
    var dataType: String
    /// The data element value length.
    var length: String
    
    /// Initializes a new `DataElement` instance
    /// - Parameters:
    ///   - name: The data element name.
    ///   - value: The data element value.
    ///   - dataType: The data element data type.
    ///   - length: The data element value length.
    ///   - customConfigFileName: The custom configuration file name used for custom ISO-8583 messages.
    init?(
        name: String,
        value: String,
        dataType: String,
        length: String,
        customConfigFileName: String? = nil
    ) {
        guard !name.isEmpty else {
            print("The name cannot be nil")
            return nil
        }
        
        if name == "DE01" {
            print("DE01 is reserved for the bitmap and cannot be added through this method.")
            return nil
        }
        
        guard DataElement.isValidDataType(dataType) else {
            print("The data type \(dataType) is invalid. Please visit http://en.wikipedia.org/wiki/ISO_8583#Data_elements to learn more about data types.")
            return nil
        }
        
        let pathToConfigFile = customConfigFileName.flatMap { Bundle.main.path(forResource: $0, ofType: "plist") } ?? Bundle.main.path(forResource: "isoconfig", ofType: "plist")
        guard let configFilePath = pathToConfigFile, let dataElementsScheme = NSDictionary(contentsOfFile: configFilePath) else {
            print("Invalid configuration file.")
            return nil
        }
        
        guard let elementLength = dataElementsScheme.value(forKeyPath: "\(name).Length") as? String else {
            print("Cannot add \(name) because it is not a valid data element defined in the ISO8583 standard or in the config file.")
            return nil
        }
        
        guard DataElement.isValueCompliant(value, with: dataType) else {
            print("The value \(value) is not compliant with data type \(dataType)")
            return nil
        }
        
        self.name = name
        self.dataType = dataType
        self.length = elementLength
        
        if (dataType == "an" || dataType == "ans"), length.range(of: "\\.") == nil {
            self.value = ISOHelper.fillStringWithBlankSpaces(value, fieldLength: length) ?? value
        } else if dataType == "n", length.range(of: "\\.") == nil {
            self.value = ISOHelper.fillStringWithZeroes(value, fieldLength: length) ?? value
        } else {
            self.value = DataElement.adjustValueForVariableLength(value: value, length: length) ?? ""
        }
    }
    
    /// Cleans up a value.
    /// - Returns: A cleaned-up value.
    func cleanValue() -> String? {
        if length.contains(".") {
            switch length.count {
            case 2:
                return String(value.dropFirst(1))
            case 4:
                return String(value.dropFirst(2))
            case 6:
                return String(value.dropFirst(3))
            default:
                return value
            }
        } else {
            if dataType == "an" || dataType == "ans" {
                return value.trimmingCharacters(in: .whitespaces)
            } else if dataType == "n" {
                return String(Double(value) ?? 0.0)
            } else {
                return value
            }
        }
    }
}

// MARK: - Validators

extension DataElement {
    /// Validates the data type specified in the data types configuration file.
    /// - Parameter dataType: The data type to be validated.
    /// - Returns: `true` if the data type is valid.
    static func isValidDataType(_ dataType: String) -> Bool {
        guard let path = Bundle.main.path(forResource: "isodatatypes", ofType: "plist"),
              let validDataTypes = NSArray(contentsOfFile: path) as? [String] else {
            return false
        }
        return validDataTypes.contains(dataType)
    }
    
    /// Determines if the value is compliant with the associated data type.
    /// - Parameters:
    ///   - value: The value.
    ///   - dataType: The data type.
    /// - Returns: `true` if the value is compliant with its associated data type.
    static func isValueCompliant(_ value: String, with dataType: String) -> Bool {
        let patterns: [String: String] = [
            "a": "^[A-Za-z\\s]+$",
            "n": "^[0-9\\.]+$",
            "s": "[^A-Za-z0-9\\s]+$",
            "an": "^[A-Za-z0-9\\s\\.]+$",
            "as": "^[A-Za-z0-9\\s\\W]+$",
            "ns": "^[0-9\\W]+$",
            "ans": "^[A-Za-z0-9\\s\\W]+$",
            "b": "^[0-9A-F]+$"
        ]
        
        guard let pattern = patterns[dataType] else {
            return dataType == "z"
        }
        
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: value.utf16.count)
        return regex?.firstMatch(in: value, options: [], range: range) != nil
    }
    
    /// Adjusts a value for a provided variable length.
    /// - Parameters:
    ///   - value: The value that needs to be adjusted.
    ///   - length: The maximum length.
    /// - Returns: The adjusted length and value as a single string.
    static func adjustValueForVariableLength(value: String, length: String) -> String? {
        guard length.contains("."), let maxLength = Int(length.dropFirst(length.count / 2)) else {
            return value.count == Int(length) ? value : nil
        }
        
        guard value.count <= maxLength else {
            print("The value length \(value.count) is greater than the provided length \(length).")
            return nil
        }
        
        let lengthDigits = length.count / 2
        let formattedLength = String(format: "%0\(lengthDigits)d", value.count)
        return formattedLength + value
    }
}

