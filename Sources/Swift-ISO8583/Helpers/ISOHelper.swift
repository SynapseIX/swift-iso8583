//
//  ISOHelper.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 11/15/24.
//

import Foundation

/// Contains helper methods to format and manipulate ISO-8583 messages.
struct ISOHelper {
    
    /// Converts a `String` to `[String]`.
    /// - Parameter string: The string to be converted.
    /// - Returns: An instance of `[String]` where each character of the original string is an individual element.
    static func stringToArray(_ string: String?) -> [String]? {
        guard let string = string else {
            return nil
        }
        
        return string.map { String($0) }
    }
    
    /// Converts a `[String]` to `String`.
    /// - Parameter array: The array to be converted.
    /// - Returns: A `String` instance of the joined array.
    static func arrayToString(_ array: [String]?) -> String? {
        guard let array = array else {
            return nil
        }
        
        return array.joined()
    }
    
    /// Converts a HEX string into a BIN one.
    /// - Parameter hexString: A string containing a HEX value.
    /// - Returns: A converted BIN string.
    static func hexToBinaryAsString(_ hexString: String?) -> String? {
        guard let hexString = hexString, !hexString.isEmpty else {
            return nil
        }
        
        let regexPattern = "^[0-9A-F]+$"
        let regex = try? NSRegularExpression(pattern: regexPattern)
        let range = NSRange(location: 0, length: hexString.utf16.count)
        
        guard let regex = regex, regex.firstMatch(in: hexString, options: [], range: range) != nil else {
            print("Parameter \(hexString) is an invalid hexadecimal number.")
            return nil
        }
        
        let conversionTable: [Character: String] = [
            "0": "0000", "1": "0001", "2": "0010", "3": "0011",
            "4": "0100", "5": "0101", "6": "0110", "7": "0111",
            "8": "1000", "9": "1001", "A": "1010", "B": "1011",
            "C": "1100", "D": "1101", "E": "1110", "F": "1111"
        ]
        
        return hexString.compactMap { conversionTable[$0] }.joined()
    }
    
    /// Converts a BIN string to HEX.
    /// - Parameter binaryString: A string containning a BIN value.
    /// - Returns: A converted HEX string
    static func binaryToHexAsString(_ binaryString: String?) -> String? {
        guard let binaryString = binaryString, !binaryString.isEmpty else {
            return nil
        }
        
        let regexPattern = "^[01]+$"
        let regex = try? NSRegularExpression(pattern: regexPattern)
        let range = NSRange(location: 0, length: binaryString.utf16.count)
        
        guard let regex = regex, regex.firstMatch(in: binaryString, options: [], range: range) != nil else {
            print("Parameter \(binaryString) is an invalid binary number.")
            return nil
        }
        
        guard binaryString.count % 4 == 0 else {
            print("Invalid binary string length (\(binaryString.count)). It must be a multiple of 4.")
            return nil
        }
        
        let conversionTable: [String: String] = [
            "0000": "0", "0001": "1", "0010": "2", "0011": "3",
            "0100": "4", "0101": "5", "0110": "6", "0111": "7",
            "1000": "8", "1001": "9", "1010": "A", "1011": "B",
            "1100": "C", "1101": "D", "1110": "E", "1111": "F"
        ]
        
        return stride(from: 0, to: binaryString.count, by: 4).compactMap {
            let startIndex = binaryString.index(binaryString.startIndex, offsetBy: $0)
            let endIndex = binaryString.index(startIndex, offsetBy: 4)
            let segment = String(binaryString[startIndex..<endIndex])
            return conversionTable[segment]
        }.joined()
    }
    
    /// Fills a string with zeroes (0) to satisfy a data element field value length requirement.
    /// - Parameters:
    ///   - string: The string that needs to be filled.
    ///   - length: The length of the field.
    /// - Returns: A string value filled with zeroes (0) of the specified length.
    static func fillStringWithZeroes(_ string: String?, fieldLength length: String?) -> String? {
        guard let string = string, let lengthStr = length, let trueLength = Int(lengthStr), string.range(of: "^[0-9]+$", options: .regularExpression) != nil else {
            return string
        }
        
        return String(repeating: "0", count: max(0, trueLength - string.count)) + string
    }
    
    /// Fills a string with zeroes blank spaces to satisfy a data element field value length requirement.
    /// - Parameters:
    ///   - string: The string that needs to be filled.
    ///   - length: The length of the field.
    /// - Returns: A string value filled with blank spaces of the specified length.
    static func fillStringWithBlankSpaces(_ string: String?, fieldLength length: String?) -> String? {
        guard let string = string, let lengthStr = length, let trueLength = Int(lengthStr), string.range(of: "^[A-Za-z0-9\\s]+$", options: .regularExpression) != nil else {
            return string
        }
        
        let spacesNeeded = max(0, trueLength - string.count)
        return string + String(repeating: " ", count: spacesNeeded)
    }
    
    /// Returns a string inside quote marks.
    /// - Parameter string: The string that needs to be enclosed in quote marks.
    /// - Returns: The string inside quote marks.
    static func limitStringWithQuotes(_ string: String?) -> String? {
        guard let string = string else {
            return nil
        }
        return "\"\(string)\""
    }
    
    /// Trims blank spaces and new lines.
    /// - Parameter string: The string that needs to be trimmed.
    /// - Returns: A trimmed string.
    static func trimString(_ string: String?) -> String? {
        return string?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

