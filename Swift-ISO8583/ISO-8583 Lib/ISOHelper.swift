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
        let regExPattern = "[0-9A-F]"
        let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
        let regExMatches = regEx?.numberOfMatchesInString(hexString!, options: nil, range: NSMakeRange(0, countElements(hexString!)))
        
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
    
    class func binaryToHexAsString(binaryString: String?) -> String? {
        if binaryString == nil {
            return nil
        }
        
        // Validate if it's a binary number
        let regExPattern = "[0-1]"
        let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
        let regExMatches = regEx?.numberOfMatchesInString(binaryString!, options: nil, range: NSMakeRange(0, countElements(binaryString!)))
        
        if regExMatches! != countElements(binaryString!) {
            println("Parameter \(binaryString) is an invalid binary number.")
            return nil;
        }
        
        // Validate that length is correct (multiple of 4)
        if countElements(binaryString!) % 4 != 0 {
            println("Invalid binary string length \(countElements(binaryString!)). It must be multiple of 4.");
            return nil;
        }
        
        let conversionTable = ["0000": "0", "0001": "1", "0010": "2", "0011": "3", "0100": "4", "0101": "5", "0110": "6", "0111": "7", "1000": "8", "1001": "9", "1010": "A", "1011": "B", "1100": "C", "1101": "D", "1110": "E", "1111": "F"]
        
        var binaryArray = NSMutableArray(capacity: countElements(binaryString!) / 4)
        var result = String()
        
        for var i = 0; i < countElements(binaryString!); i += 4 {
            var substringFrom = (binaryString! as NSString).substringFromIndex(i) as NSString
            var substringTo = substringFrom.substringToIndex(4)
            
            binaryArray.addObject(substringTo)
            result += conversionTable[binaryArray.objectAtIndex(i / 4) as String]!
        }
        
        return result
    }
    
    class func fillStringWithZeroes(string: String?, fieldLength: String?) -> String? {
        if string == nil {
            return nil
        }
        
        if fieldLength == nil {
            return nil
        }
        
        if (fieldLength! as NSString).rangeOfString(".").location != NSNotFound {
            println("The length format is not correct.")
            return string;
        }
        
        let trueLength = fieldLength?.toInt()
        let regExPattern = "[0-9]"
        let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
        let regExMatches = regEx?.numberOfMatchesInString(string!, options: nil, range: NSMakeRange(0, countElements(string!)))
        
        if regExMatches != countElements(string!) {
            println("The string provided \"\(string)\" is not a numeric string and cannot be filled with zeroes (0).")
            return string
        }
        
        if (countElements(string!) >= trueLength) {
            return string
        }
        
        let zeroesNeeded = trueLength! - countElements(string!)
        var result = String()
        
        for var i = 0; i < zeroesNeeded; i++ {
            result += "0"
        }
        
        result += string!
        
        return result
    }
    
    class func fillStringWithBlankSpaces(string: String?, fieldLength: String?) -> String? {
        if string == nil {
            return nil
        }
        
        if fieldLength == nil {
            return nil
        }
        
        if (fieldLength! as NSString).rangeOfString(".").location != NSNotFound {
            println("The length format is not correct.")
            return string;
        }
        
        let trueLength = fieldLength?.toInt()
        let regExPattern = "[A-Za-z0-9\\s]"
        let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
        let regExMatches = regEx?.numberOfMatchesInString(string!, options: nil, range: NSMakeRange(0, countElements(string!)))
        
        if regExMatches != countElements(string!) {
            println("The string provided \"\(string)\" is not an alphanumeric string and cannot be filled with blank spaces.")
            return string
        }
        
        if countElements(string!) >= trueLength {
            return string
        }
        
        let blankSpacesNeeded = trueLength! - countElements(string!)
        var result = String()
        
        for var i = 0; i < blankSpacesNeeded; i++ {
            result += " "
        }
        
        return string! + result
    }
    
    class func limitStringWithQuotes(string: String?) -> String? {
        if string == nil {
            return nil
        }
        
        return "\"\(string)\""
    }
    
    class func trimString(string: String?) -> String? {
        if string == nil {
            return nil
        }
        
        return string?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}