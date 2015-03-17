//
//  ISODataElement.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 3/15/15.
//  Copyright (c) 2015 Jorge Tapia. All rights reserved.
//

import Foundation

class ISODataElement {
    private(set) var name: String?
    private(set) var value: String?
    private(set) var dataType: String?
    private(set) var length: String?
    
    // MARK: Initializers
    init?(name: String, value: String, dataType: String, length: String, configFileName: String?) {
        if name.isEmpty {
            println("The name cannot be empty.")
            return nil
        }
        
        if dataType.isEmpty || dataType == "DE01" {
            println("DE01 is reserved for the bitmap and cannot be added through this method.")
            return nil;
        }
        
        if isValidDataType(dataType) {
            println("The data type \(dataType) is invalid. Please visit http://en.wikipedia.org/wiki/ISO_8583#Data_elements to learn more about data types.")
            return nil;
        }
        
        let pathToConfigFile = configFileName != nil ? NSBundle.mainBundle().pathForResource("isoconfig", ofType: "plist") : NSBundle.mainBundle().pathForResource(configFileName, ofType: "plist")
        let dataElementsScheme = NSDictionary(contentsOfFile: pathToConfigFile!)!
        
        if dataElementsScheme.objectForKey(name) != nil {
            let dataElementLength = dataElementsScheme.valueForKeyPath("\(name).length") as String
            
            // validate with data type
            if !isValueCompliantWithDataType(value, dataType: dataType) {
                println("The value \"\(value)\" is not compliant with data type \"\(dataType)\"")
                return nil;
            }
            
            self.name = name
            self.dataType = dataType
            self.length = length
            
            // set value according to length and data type
            if dataType == "an" || dataType == "ans" && (length as NSString).rangeOfString(".").location == NSNotFound {
                self.value = ISOHelper.fillStringWithBlankSpaces(value, fieldLength: length)
            } else if dataType == "n" && (length as NSString).rangeOfString(".").location == NSNotFound {
                self.value = ISOHelper.fillStringWithZeroes(value, fieldLength: length)
            } else {
                // value has variable length
                if (length as NSString).rangeOfString(".").location != NSNotFound {
                    var maxLength = -1
                    var numberOfLengthDigits = -1
                    var trueLength = String()
                    
                    if (countElements(length) == 2) {
                        maxLength = length.substringFromIndex(advance(length.startIndex, 1)).toInt()!;
                        numberOfLengthDigits = 1
                    } else if (countElements(length) == 4) {
                        maxLength = length.substringFromIndex(advance(length.startIndex, 2)).toInt()!;
                        numberOfLengthDigits = 2
                    } else if (countElements(length) == 6) {
                        maxLength = length.substringFromIndex(advance(length.startIndex, 3)).toInt()!;
                        numberOfLengthDigits = 3
                    }
                    
                    // validate length of value
                    if (countElements(value) > maxLength) {
                        println("The value length \"\(countElements(value))\" is greater to the provided length \"\(length)\".")
                        return nil
                    }
                    
                    // fill with zeroes if needed
                    if numberOfLengthDigits == 1 {
                        trueLength = "\(countElements(value))"
                    }
                    
                    if numberOfLengthDigits == 2 && countElements(value) < 10 {
                        trueLength = "0\(countElements(value))"
                    } else {
                        trueLength = "\(countElements(value))"
                    }
                    
                    if numberOfLengthDigits == 3 && countElements(value) < 10 {
                        trueLength = "00\(countElements(value))"
                    } else if numberOfLengthDigits == 3 && countElements(value) >= 10 && countElements(value) < 100 {
                        trueLength = "0\(countElements(value))"
                    } else if numberOfLengthDigits == 3 && countElements(value) >= 100 && countElements(value) < 1000 {
                        trueLength = "\(countElements(value))"
                    }
                    
                    self.value = "\(trueLength)\(value)"
                } else {
                    // has no variable value
                    if (countElements(value) == length.toInt()) {
                        self.value = value;
                    } else {
                        println("The value \"\(value)\" length is not equal to the provided length \"\(length)\".");
                        return nil;
                    }
                }
            }
        } else {
            println("Cannot add \(name) because it is not a valid data element defined in the ISO8583 standard or in the isoconfig.plist file or in your custom config file. Please visit http://en.wikipedia.org/wiki/ISO_8583#Data_elements to learn more about data elements.")
            
            return nil;
        }
    }
    
    // MARK: Methods
    
    func getCleanValue() -> String? {
        var cleanValue: String? = nil
        var theLength = length! as NSString
        
        if theLength.rangeOfString(".").location != NSNotFound {
            var fromIndex = advance(value!.startIndex, 1);
            
            if countElements(length!) == 2 {
                cleanValue = value!.substringFromIndex(fromIndex)
            } else if countElements(length!) == 4 {
                fromIndex = advance(value!.startIndex, 2);
                cleanValue = value!.substringFromIndex(fromIndex)
            } else if countElements(length!) == 6 {
                fromIndex = advance(value!.startIndex, 3);
                cleanValue = value!.substringFromIndex(fromIndex)
            }
        } else {
            if dataType == "an" || dataType == "ans" {
                return value!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            } else if dataType == "n" {
                let number = (value! as NSString).floatValue
                cleanValue = "\(number)";
            } else {
                cleanValue = value!
            }
        }
        
        return cleanValue
    }
    
    // MARK: Private methods
    
    private func isValidDataType(dataType: String) -> Bool {
        let pathToDataTypeConfigFile = NSBundle.mainBundle().pathForResource("isodatatypes", ofType: "plist")
        let validDataTypes = NSArray(contentsOfFile: pathToDataTypeConfigFile!)
        
        return validDataTypes?.indexOfObject(dataType) > -1
    }
    
    private func isValueCompliantWithDataType(value: String, dataType: String) -> Bool {
        if dataType == "a" {
            let regExPattern = "[A-Za-z\\s]"
            let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
            let regExMatches = regEx?.numberOfMatchesInString(value, options: nil, range: NSMakeRange(0, countElements(value)))
            
            if regExMatches != countElements(value) {
                return false
            } else {
                return true
            }
        }
        
        if dataType == "n" {
            let regExPattern = "[0-9\\.]"
            let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
            let regExMatches = regEx?.numberOfMatchesInString(value, options: nil, range: NSMakeRange(0, countElements(value)))
            
            if regExMatches != countElements(value) {
                return false
            } else {
                return true
            }
        }
        
        if dataType == "s" {
            let regExPattern = "[^A-Za-z0-9\\s]"
            let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
            let regExMatches = regEx?.numberOfMatchesInString(value, options: nil, range: NSMakeRange(0, countElements(value)))
            
            if regExMatches != countElements(value) {
                return false
            } else {
                return true
            }
        }
        
        if dataType == "an" {
            let regExPattern = "[A-Za-z0-9\\s\\.]"
            let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
            let regExMatches = regEx?.numberOfMatchesInString(value, options: nil, range: NSMakeRange(0, countElements(value)))
            
            if regExMatches != countElements(value) {
                return false
            } else {
                return true
            }
        }
        
        if dataType == "as" {
            let regExPattern = "[A-Za-z0-9\\s\\W]"
            let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
            let regExMatches = regEx?.numberOfMatchesInString(value, options: nil, range: NSMakeRange(0, countElements(value)))
            
            if regExMatches != countElements(value) {
                return false
            } else {
                return true
            }
        }
        
        if dataType == "ans" {
            let regExPattern = "[A-Za-z0-9\\s\\W]"
            let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
            let regExMatches = regEx?.numberOfMatchesInString(value, options: nil, range: NSMakeRange(0, countElements(value)))
            
            if regExMatches != countElements(value) {
                return false
            } else {
                return true
            }
        }
        
        if dataType == "b" {
            let regExPattern = "[0-9A-F]"
            let regEx = NSRegularExpression(pattern: regExPattern, options: nil, error: nil)
            let regExMatches = regEx?.numberOfMatchesInString(value, options: nil, range: NSMakeRange(0, countElements(value)))
            
            if regExMatches != countElements(value) {
                return false
            } else {
                return true
            }
        }
        
        if dataType == "z" {
            // TODO: correctly validate type z
            return true
        }
        
        return false
    }
}