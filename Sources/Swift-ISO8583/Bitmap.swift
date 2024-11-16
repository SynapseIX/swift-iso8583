//
//  Bitmap.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 11/15/24.
//

import Foundation

/// Represents the bitmap that determines which data elements are present on the ISO-8583 message.
public struct Bitmap {
    /// The raw string value of the ISO-8583 message.
    public let rawValue: String
    /// Determines if the message has a secondary bitmap.
    public let hasSecondaryBitmap: Bool
    ///  Determines if it is a BIN bitmap.
    public let isBinary: Bool
    /// An array representation of a BIN bitmap.
    public let binaryBitmap: [String]
    
    /// Initializes a new bitmap instance from a string containing a BIN value.
    /// - Parameter binaryString: The BIN bitmap string.
    public init?(binaryString: String) {
        // Validate if it's a binary number
        let regexPattern = "^[0-1]+$"
        guard let regex = try? NSRegularExpression(pattern: regexPattern),
              regex.firstMatch(in: binaryString, options: [], range: NSRange(location: 0, length: binaryString.utf16.count)) != nil else {
            print("Parameter \(binaryString) is an invalid binary number.")
            return nil
        }
        
        self.hasSecondaryBitmap = binaryString.prefix(1) == "1"
        
        if hasSecondaryBitmap && binaryString.count != 128 {
            print("Invalid bitmap. Bitmap length must be 128 if the first bit is 1.")
            return nil
        } else if !hasSecondaryBitmap && binaryString.count != 64 {
            print("Invalid bitmap. Bitmap length must be 64 if the first bit is 0.")
            return nil
        }
        
        self.rawValue = binaryString
        self.isBinary = true
        self.binaryBitmap = ISOHelper.stringToArray(binaryString) ?? []
    }
    
    /// Initializes a new bitmap instance from a string containing a HEX value.
    /// - Parameter hexString: The HEX bitmap string.
    public init?(hexString: String) {
        // Validate if it's a hexadecimal number
        let regexPattern = "^[0-9A-F]+$"
        guard let regex = try? NSRegularExpression(pattern: regexPattern),
              regex.firstMatch(in: hexString, options: [], range: NSRange(location: 0, length: hexString.utf16.count)) != nil else {
            print("Parameter \(hexString) is an invalid hexadecimal number.")
            return nil
        }
        
        self.hasSecondaryBitmap = ["8", "9", "A", "B", "C", "D", "E", "F"].contains(String(hexString.prefix(1)))
        
        if hasSecondaryBitmap && hexString.count != 32 {
            print("Invalid bitmap. Hexadecimal bitmap length must be 32 if the first byte is not 0.")
            return nil
        } else if !hasSecondaryBitmap && hexString.count != 16 {
            print("Invalid bitmap. Bitmap length must be 16 if the first byte is 0.")
            return nil
        }
        
        self.rawValue = hexString
        self.isBinary = false
        guard let binaryString = ISOHelper.hexToBinaryAsString(hexString) else {
            return nil
        }
        self.binaryBitmap = ISOHelper.stringToArray(binaryString) ?? []
    }
    
    /// Initializes a bitmap with a predefine list of data elements.
    /// - Parameters:
    ///   - givenDataElements: The data elements that will be present on the bitmap.
    ///   - configFileName: The custom configuration file for custom ISO-8583 messages.
    public init?(givenDataElements: [String], configFileName: String? = nil) {
        self.isBinary = true
        let pathToConfigFile = configFileName.flatMap { Bundle.main.path(forResource: $0, ofType: "plist") } ?? Bundle.module.path(forResource: "isoconfig", ofType: "plist")
        guard let configFilePath = pathToConfigFile, let dataElementsScheme = NSDictionary(contentsOfFile: configFilePath) else {
            print("Invalid configuration file.")
            return nil
        }
        
        var bitmapTemplate = Array(repeating: "0", count: 128)
        
        for dataElement in givenDataElements {
            if dataElement == "DE01" {
                print("You cannot add DE01 explicitly, its value is automatically inferred.")
                return nil
            }
            
            guard dataElementsScheme[dataElement] != nil else {
                print("Cannot add \(dataElement) because it is not a valid data element defined in the ISO8583 standard or in the config file.")
                return nil
            }
            
            let indexToUpdate = Int(dataElement.suffix(dataElement.count - 2))! - 1
            bitmapTemplate[indexToUpdate] = "1"
        }
        
        // Check if it has a secondary bitmap (contains DE65...DE128)
        if givenDataElements.contains(where: { Int($0.suffix($0.count - 2))! > 63 }) {
            bitmapTemplate[0] = "1"
            self.hasSecondaryBitmap = true
        } else {
            self.hasSecondaryBitmap = false
        }
        
        self.rawValue = hasSecondaryBitmap ? bitmapTemplate.joined() : bitmapTemplate.prefix(64).joined()
        self.binaryBitmap = Array(bitmapTemplate.prefix(hasSecondaryBitmap ? 128 : 64))
    }
    
    /// A BIN represnetation of the bitmap.
    /// - Returns: A string containing the bitmap as a BIN value.
    public func bitmapAsBinaryString() -> String {
        return isBinary ? rawValue : (ISOHelper.hexToBinaryAsString(rawValue) ?? "")
    }
    
    /// A HEX represnetation of the bitmap.
    /// - Returns: A string containing the bitmap as a HEX value.
    public func bitmapAsHexString() -> String {
        return !isBinary ? rawValue : (ISOHelper.binaryToHexAsString(rawValue) ?? "")
    }
    
    /// Extracts a list of the data elements that are declared in the bitmap.
    /// - Returns: An array of data element names as strings.
    public func dataElementsInBitmap() -> [String] {
        let pathToConfigFile = Bundle.module.path(forResource: "isoconfig", ofType: "plist")
        guard let configFilePath = pathToConfigFile, let dataElementsScheme = NSDictionary(contentsOfFile: configFilePath) else {
            return []
        }
        
        var dataElements: [String] = []
        for (i, bit) in binaryBitmap.enumerated() where bit == "1" {
            let key: String
            let sortedKeys = dataElementsScheme.allKeys.sorted { (a, b) -> Bool in
                guard let strA = a as? String, let strB = b as? String else { return false }
                return strA.compare(strB, options: .numeric) == .orderedAscending
            }
            key = sortedKeys[i] as? String ?? ""
            
            if dataElementsScheme[key] != nil {
                dataElements.append(key)
            }
        }
        
        return dataElements
    }
}

