//
//  ISOMessage.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 3/14/15.
//  Copyright (c) 2015 Jorge Tapia. All rights reserved.
//

import Foundation

class ISOMessage {
    // MARK: Properties
    
    private(set) var mti: String?
    var bitmap: ISOBitmap?
    private(set) var hasSecondaryBitmap: Bool
    private(set) var usesCustomConfiguration: Bool
    
    var dataElements: NSMutableDictionary?
    
    private var dataElementsScheme: NSDictionary
    private var validMTIs: NSArray
    
    // MARK: Initializers
    
    init() {
        let pathToConfigFile = NSBundle.mainBundle().pathForResource("isoconfig", ofType: "plist")
        dataElementsScheme = NSMutableDictionary(contentsOfFile: pathToConfigFile!)!
        dataElements = NSMutableDictionary(capacity: dataElementsScheme.count)
        
        let pathToMTIConfigFile = NSBundle.mainBundle().pathForResource("isoMTI", ofType: "plist")
        validMTIs = NSArray(contentsOfFile: pathToMTIConfigFile!)!
        
        usesCustomConfiguration = false
        hasSecondaryBitmap = false
    }
    
    convenience init?(isoMessage: String?) {
        self.init()
        
        if isoMessage == nil {
            println("The isoMessage parameter cannot be nil.")
            return nil
        }
        
        let isoHeaderPresent = isoMessage!.substringToIndex(advance(isoMessage!.startIndex, 3)) == "ISO"
        
        if !isoHeaderPresent {
            // Sets MTI
            setMTI(isoMessage!.substringToIndex(advance(isoMessage!.startIndex, 4)))
            
            let startBitmapFirstBitIndex = advance(isoMessage!.startIndex, 4)
            let endBitmapFirstBitIndex = advance(startBitmapFirstBitIndex, 1)
            let bitmapFirstBit = isoMessage!.substringWithRange(Range(start: startBitmapFirstBitIndex, end: endBitmapFirstBitIndex))
            
            // Sets bitmap
            hasSecondaryBitmap = bitmapFirstBit == "8" || bitmapFirstBit == "9" || bitmapFirstBit == "A" || bitmapFirstBit == "B" || bitmapFirstBit == "C" || bitmapFirstBit == "D" || bitmapFirstBit == "E" || bitmapFirstBit == "F"
            
            let endBitmapIndex = hasSecondaryBitmap ? advance(startBitmapFirstBitIndex, 32) : advance(startBitmapFirstBitIndex, 16)
            let bitmapRange = Range(start: startBitmapFirstBitIndex, end: endBitmapIndex)
            let bitmapHexString = isoMessage!.substringWithRange(bitmapRange)
            
            bitmap = ISOBitmap(hexString: bitmapHexString)
            
            // Extract and set values for data elements
            let dataElementValues = isoMessage!.substringFromIndex(endBitmapIndex)
            let theValues = extractDataElementValues(dataElementValues, dataElements: bitmap?.dataElementsInBitmap())
            
            println("MTI: \(mti!)")
            println("Bitmap: \(bitmap!.rawValue!)")
            println("Data: \(dataElementValues)")
        } else {
            // TODO: with iso header
        }
    }
    
    // MARK: Methods
    
    func setMTI(mti: String) -> Bool {
        if (isValidMTI(mti)) {
            self.mti = mti
            return true
        } else {
            println("The MTI is not valid. Please set a valid MTI like the ones described in the isoMTI.plist or your custom MTI configuration file.")
            return false
        }
    }
    
    func addDataElement(elementName: String?, value: String?) -> Bool {
        return addDataElement(elementName, value: value, customConfigFileName: nil)
    }
    
    func addDataElement(elementName: String?, value: String?, customConfigFileName: String?) -> Bool {
        return false
    }
    
    func useCustomConfigurationFiles(customConfigurationFileName: String?, customMTIFileName: String?) -> Bool {
        if customConfigurationFileName == nil {
            println("The customConfigurationFileName cannot be nil.")
            return false
        }
        
        if customMTIFileName == nil {
            println("The customMTIFileName cannot be nil.")
            return false
        }
        
        let pathToConfigFile = NSBundle.mainBundle().pathForResource(customConfigurationFileName, ofType: "plist")
        dataElementsScheme = NSDictionary(contentsOfFile: pathToConfigFile!)!
        dataElements = NSMutableDictionary()
        
        let pathToMTIConfigFile = NSBundle.mainBundle().pathForResource(customMTIFileName, ofType: "plist")
        validMTIs = NSArray(contentsOfFile: pathToMTIConfigFile!)!
        
        usesCustomConfiguration = true
        
        return true
    }
    
    func getHexBitmap1() -> String? {
        let hexBitmapString = (bitmap?.bitmapAsHexString())!
        return hexBitmapString.substringToIndex(advance(hexBitmapString.startIndex, 16))
    }
    
    func getBinaryBitmap1() -> String? {
        let binaryBitmapString = ISOHelper.hexToBinaryAsString(bitmap?.bitmapAsHexString())!
        return binaryBitmapString.substringToIndex(advance(binaryBitmapString.startIndex, 64))
    }
    
    func getHexBitmap2() -> String? {
        let isBinary = bitmap!.isBinary
        let length = countElements(bitmap!.rawValue!)
        
        if isBinary && length != 128 {
            println("This bitmap does not have a secondary bitmap.")
            return nil
        } else if !isBinary && length != 32 {
            println("This bitmap does not have a secondary bitmap.")
            return nil
        } else if isBinary && length == 128 {
            return ISOHelper.binaryToHexAsString(bitmap!.rawValue!.substringFromIndex(advance(bitmap!.rawValue!.startIndex, 64)))
        } else if isBinary && length == 32 {
            return ISOHelper.binaryToHexAsString(bitmap!.rawValue!.substringFromIndex(advance(bitmap!.rawValue!.startIndex, 16)))
        }
        
        return nil
    }
    
    // MARK: Private methods
    
    private func isValidMTI(mti: String) -> Bool {
        return validMTIs.indexOfObject(mti) > -1
    }
    
    private func extractDataElementValues(isoMessageDataElementValues: String?, dataElements: [String]?) -> [String]? {
        var dataElementCount = 0
        var fromIndex = -1
        var toIndex = -1
        var values = [String]()
        
        for dataElement in dataElements! {
            if dataElement == "DE01" {
                continue
            }
            
            let length = dataElementsScheme.valueForKeyPath("\(dataElement).Length") as NSString
            
            // fixed length values
            if length.rangeOfString(".").location == NSNotFound {
                var trueLength = (length as String).toInt()
                
                if dataElementCount == 0 {
                    fromIndex = 0
                    toIndex = trueLength!
                    
                    let valuesAsNSString = isoMessageDataElementValues! as NSString
                    let value = (valuesAsNSString.substringFromIndex(fromIndex) as NSString).substringToIndex(toIndex)
                    values.append(value)
                    fromIndex = trueLength!
                } else {
                    toIndex = trueLength!
                    let valuesAsNSString = isoMessageDataElementValues! as NSString
                    let value = (valuesAsNSString.substringFromIndex(fromIndex) as NSString).substringToIndex(toIndex)
                    values.append(value)
                    fromIndex += trueLength!
                }
            } else {
                // variable length values
                var trueLength = -1
                var numberOfLengthDigits = 0
                let valuesAsNSString = isoMessageDataElementValues! as NSString
                
                if countElements(length as String) == 2 {
                    numberOfLengthDigits = 1
                } else if countElements(length as String) == 4 {
                    numberOfLengthDigits = 2
                } else if countElements(length as String) == 6 {
                    numberOfLengthDigits = 3
                }
                
                if dataElementCount == 0 {
                    trueLength = (valuesAsNSString.substringFromIndex(fromIndex) as NSString).substringToIndex(toIndex).toInt()! + numberOfLengthDigits
                    fromIndex = 0 + numberOfLengthDigits
                    toIndex = trueLength - numberOfLengthDigits
                    let value = (valuesAsNSString.substringFromIndex(fromIndex) as NSString).substringToIndex(toIndex)
                    values.append(value)
                    fromIndex = trueLength;
                } else {
                    trueLength = (valuesAsNSString.substringFromIndex(fromIndex) as NSString).substringToIndex(numberOfLengthDigits).toInt()! + numberOfLengthDigits
                    toIndex = trueLength
                    let value = (valuesAsNSString.substringToIndex(fromIndex + numberOfLengthDigits) as NSString).substringToIndex(toIndex - numberOfLengthDigits)
                    values.append(value)
                    fromIndex += trueLength
                }
            }
            
            dataElementCount++;
        }
        
        return values
    }
}
