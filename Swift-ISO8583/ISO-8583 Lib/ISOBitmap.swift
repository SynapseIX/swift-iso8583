//
//  ISOBitmap.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 3/15/15.
//  Copyright (c) 2015 Jorge Tapia. All rights reserved.
//

import Foundation

class ISOBitmap {
    // MARK: Properties
    private(set) var binaryBitmap: [String]?
    private(set) var hasSecondaryBitmap: Bool = false
    private(set) var rawValue: String?
    private(set) var isBinary: Bool = false
    
    // MARK: Initializers
    init?(binaryString: String?) {
        if binaryString == nil {
            return nil
        }
        
        // Validate if it's a binary number
        let regExPattern = "[0-1]"
        let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
        let regExMatches = regEx?.numberOfMatchesInString(binaryString!, options: nil, range: NSMakeRange(0, countElements(binaryString!)))
        
        if regExMatches != countElements(binaryString!) {
            println("Parameter \(binaryString!) is an invalid binary number.")
            return nil;
        }
        
        let firstCharacterIndex = advance(binaryString!.startIndex, 1)
        hasSecondaryBitmap = binaryString?.substringToIndex(firstCharacterIndex) == "1"
        
        if hasSecondaryBitmap && countElements(binaryString!) != 128 {
            println("Invalid bitmap. Bitmap length must be 128 if the first bit is 1.")
            return nil
        } else if !hasSecondaryBitmap && countElements(binaryString!) != 64 {
            println("Invalid bitmap. Bitmap length must be 64 if the first bit is 0.")
            return nil
        } else {
            rawValue = binaryString
            isBinary = true
            binaryBitmap = ISOHelper.stringToArray(binaryString)
        }
    }
    
    init?(hexString: String?) {
        if hexString == nil {
            return nil
        }
        
        // Validate if it's a binary number
        let regExPattern = "[0-9A-F]"
        let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
        let regExMatches = regEx?.numberOfMatchesInString(hexString!, options: nil, range: NSMakeRange(0, countElements(hexString!)))
        
        if regExMatches != countElements(hexString!) {
            println("Parameter \(hexString!) is an invalid binary number.")
            return nil;
        }
        
        let firstCharacterIndex = advance(hexString!.startIndex, 1)
        hasSecondaryBitmap = hexString?.substringToIndex(firstCharacterIndex) == "8" || hexString?.substringToIndex(firstCharacterIndex) == "9" || hexString?.substringToIndex(firstCharacterIndex) == "A" || hexString?.substringToIndex(firstCharacterIndex) == "B" || hexString?.substringToIndex(firstCharacterIndex) == "C" || hexString?.substringToIndex(firstCharacterIndex) == "D" || hexString?.substringToIndex(firstCharacterIndex) == "E" || hexString?.substringToIndex(firstCharacterIndex) == "F"
        
        if hasSecondaryBitmap && countElements(hexString!) != 32 {
            println("Invalid bitmap. Bitmap length must be 32 if the first bit is 1.")
            return nil
        } else if !hasSecondaryBitmap && countElements(hexString!) != 16 {
            println("Invalid bitmap. Bitmap length must be 16 if the first bit is 0.")
            return nil
        } else {
            rawValue = hexString
            isBinary = true
            binaryBitmap = ISOHelper.stringToArray(ISOHelper.hexToBinaryAsString(hexString))
        }
    }
    
    init?(givenDataElements: [String]?, customConfigFileName: String?) {
        if givenDataElements == nil {
            return nil
        }
        
        let pathToConfigFile = customConfigFileName != nil ? NSBundle.mainBundle().pathForResource("isoconfig", ofType: "plist") : NSBundle.mainBundle().pathForResource(customConfigFileName, ofType: "plist")
        let dataElementsScheme = NSDictionary(contentsOfFile: pathToConfigFile!)
        var bitmapTemplate = ISOHelper.stringToArray("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")!
        
        for dataElement in givenDataElements! {
            if dataElement == "DE01" {
                println("You cannot add DE01 explicitly, its value is automatically inferred.")
                return nil
            }
            
            if dataElementsScheme?.objectForKey(dataElement) != nil {
                println("Cannot add \(dataElement) because it is not a valid data element defined in the ISO8583 standard or in the isoconfig.plist file or in your custom config file. Please visit http://en.wikipedia.org/wiki/ISO_8583#Data_elements to learn more about data elements.")
                return nil
            } else {
                // mark the data element on the bitmap
                let index = (dataElement as NSString).substringFromIndex(2).toInt()! - 1
                bitmapTemplate[index] = "1"
                
            }
        }
        
        // Check if it has a secondary bitmap (contains DE65...DE128)
        for dataElement in givenDataElements! {
            let index = (dataElement as NSString).substringFromIndex(2).toInt()! - 1
            
            if index > 63 {
                bitmapTemplate[index] = "1"
                hasSecondaryBitmap = true
                break
            }
            
            if hasSecondaryBitmap {
                rawValue = ISOHelper.arrayToString(bitmapTemplate)
                binaryBitmap = bitmapTemplate
            } else {
                let bitmapTemplateAsString = ISOHelper.arrayToString(bitmapTemplate)
                
                rawValue = bitmapTemplateAsString?.substringToIndex(advance(bitmapTemplateAsString!.startIndex, 64))
                binaryBitmap = ISOHelper.stringToArray(rawValue)
            }
        }
    }
    
    convenience init?(givenDataElements: [String]?) {
        self.init(givenDataElements: givenDataElements, customConfigFileName: nil)
    }
    
    // MARK: Methods
    func bitmapAsBinaryString() -> String? {
        return isBinary ? rawValue : ISOHelper.hexToBinaryAsString(rawValue);
    }
    
    func bitmapAsHexString() -> String? {
        return !isBinary ? rawValue : ISOHelper.binaryToHexAsString(rawValue);
    }
    
    func dataElementsInBitmap() -> [String]? {
        return dataElementsInBitmap(nil)
    }
    
    func dataElementsInBitmap(customConfigFileName: String?) -> [String]? {
        let pathToConfigFile = customConfigFileName == nil ? NSBundle.mainBundle().pathForResource("isoconfig", ofType: "plist") : NSBundle.mainBundle().pathForResource(customConfigFileName, ofType: "plist")
        let dataElementsScheme = NSDictionary(contentsOfFile: pathToConfigFile!)
        var dataElements = [String]()
        
        for var i = 0; i < binaryBitmap?.count; i++ {
            var bit = binaryBitmap![i]
            
            if bit == "1" {
                var index = String(i);
                var key = String()
                
                if customConfigFileName != nil {
                    key = countElements(index) == 1 ? "DE0\(i + 1)" : "DE\(i + 1)"
                } else {
                    let sortDescriptor = NSSortDescriptor(key: String(), ascending: true, comparator: {(object1: AnyObject!, object2: AnyObject!) -> NSComparisonResult in
                        return (object1 as String).compare((object2 as String), options: NSStringCompareOptions.NumericSearch)
                    })
                    let sortedKeys = (dataElementsScheme!.allKeys as NSArray).sortedArrayUsingDescriptors([sortDescriptor])
                    key = sortedKeys[i] as String
                }
                
                if dataElementsScheme?.objectForKey(key) != nil {
                    dataElements.append(key)
                }
            }
        }
        
        return dataElements
    }
}