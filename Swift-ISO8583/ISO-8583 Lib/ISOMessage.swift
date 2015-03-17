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
    
    private let dataElementsScheme: NSDictionary
    private let validMTIs: NSArray
    
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
    
    convenience init?(isoMessage: String) {
        self.init()
        
        if isoMessage.isEmpty {
            println("The isoMessage parameter cannot be empty.")
            return nil
        }
        
        let isoHeaderPresent = isoMessage.substringToIndex(advance(isoMessage.startIndex, 3)) == "ISO"
        
        if !isoHeaderPresent {
            // Sets MTI
            setMTI(isoMessage.substringToIndex(advance(isoMessage.startIndex, 4)))
            
            let startBitmapFirstBitIndex = advance(isoMessage.startIndex, 4)
            let endBitmapFirstBitIndex = advance(startBitmapFirstBitIndex, 1)
            let bitmapFirstBit = isoMessage.substringWithRange(Range(start: startBitmapFirstBitIndex, end: endBitmapFirstBitIndex))
            
            // Sets bitmap
            hasSecondaryBitmap = bitmapFirstBit == "8" || bitmapFirstBit == "9" || bitmapFirstBit == "A" || bitmapFirstBit == "B" || bitmapFirstBit == "C" || bitmapFirstBit == "D" || bitmapFirstBit == "E" || bitmapFirstBit == "F"
            
            let endBitmapIndex = hasSecondaryBitmap ? advance(startBitmapFirstBitIndex, 32) : advance(startBitmapFirstBitIndex, 16)
            let bitmapRange = Range(start: startBitmapFirstBitIndex, end: endBitmapIndex)
            let bitmapHexString = isoMessage.substringWithRange(bitmapRange)
            
            bitmap = ISOBitmap(hexString: bitmapHexString)
            
            // Extract and set values for data elements
            let dataElementValuesRange = Range(start: endBitmapIndex, end: isoMessage.endIndex)
            let dataElementValues = isoMessage.substringWithRange(dataElementValuesRange)
            
            // TODO: extract the values for all data elements as an array and add them to the isoMessage object
            
            println("MTI: \(mti)")
            println("Bitmap: \(bitmapHexString)") // TODO: change it with ISOBitmap.rawValue
            println("Data: \(dataElementValues)")
        } else {
            // TODO: build message when ISO header is present
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
    
    // MARK: Private methods
    
    private func isValidMTI(mti: String) -> Bool {
        return validMTIs.indexOfObject(mti) > -1
    }
}
