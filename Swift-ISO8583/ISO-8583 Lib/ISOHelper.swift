//
//  ISOHelper.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 3/15/15.
//  Copyright (c) 2015 Jorge Tapia. All rights reserved.
//

import Foundation

class ISOHelper {
    class func stringToArray(string: String?) -> [String]? {
        if string == nil {
            return nil
        }
        
        var chars = [String]()
        
        for char in string! {
            chars.append("\(char)")
        }
        
        return chars
    }
    
    class func arrayToString(array: [String]?) -> String? {
        if array == nil {
            return nil
        }
        
        var string = String()
        
        for char in array! {
            string.append(Character(char))
        }
        
        return string
    }
    
    class func hexToBinaryAsString(hexString: String?) -> String? {
        if hexString == nil {
            return nil
        }
        
        // Validate if it's a hexadecimal number
        var regExPattern = "[0-9A-F]"
        var regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
        var regExMatches = regEx?.numberOfMatchesInString(hexString!, options: nil, range: NSMakeRange(0, countElements(hexString!)))
        
        if regExMatches! != countElements(hexString!) {
            println("Parameter \(hexString) is an invalid hexadecimal number.")
            return nil;
        }
        
        let conversionTable = ["0": "0000", "1": "0001", "2": "0010", "3": "0011", "4": "0100", "5": "0101", "6": "0110", "7": "0111", "8": "1000", "9": "1001", "A": "1010", "B": "1011", "C": "1100", "D": "1101", "E": "1110", "F": "1111"]
        
        let hexArray = stringToArray(hexString)!
        var result = String()
        
        for hexNumber in hexArray {
            result += conversionTable[hexNumber]!
        }
        
        return result
    }
    
    class func binaryToHexAsString(binaryString: String) -> String {
        return String()
    }
    
    class func fillStringWithZeroes(string: String, fieldLength: String) -> String {
        return String()
    }
    
    class func fillStringWithBlankSpaces(string: String, fieldLength: String) -> String {
        return String()
    }
    
    class func limitStringWithQuotes(string: String) -> String {
        return String()
    }
    
    class func trimString(string: String) -> String {
        return String()
    }

}