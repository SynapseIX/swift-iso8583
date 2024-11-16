//
//  ISOMessage.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 11/15/24.
//

import Foundation

/// The ISO-8583 message representation.
struct ISOMessage {
    /// The scheme that defines the data elements the message expects.
    var dataElementsScheme: NSDictionary?
    /// The data elements in the message.
    var dataElements: [String: DataElement] = [:]
    /// Valid MTIs for the message.
    var validMTIs: [String] = []
    /// Determines if a custom configuration should be used.
    var usesCustomConfiguration = false
    /// The message MTI.
    var mti: String?
    /// The message bitmap.
    var bitmap: Bitmap?
    /// Determines if this message contains a secondary bitmap.
    var hasSecondaryBitmap = false
    
    /// Initializes a new `ISOMessage` instance with the deafult configuration.
    init() {
        if let pathToConfigFile = Bundle.main.path(forResource: "isoconfig", ofType: "plist") {
            dataElementsScheme = NSDictionary(contentsOfFile: pathToConfigFile)
        }
        
        if let pathToMTIConfigFile = Bundle.main.path(forResource: "isoMTI", ofType: "plist"),
           let mtis = NSArray(contentsOfFile: pathToMTIConfigFile) as? [String] {
            validMTIs = mtis
        }
    }
    
    /// Initializes a new `ISOMessage` instance from a string.
    /// - Parameter isoMessage: The message as a string value.
    init?(isoMessage: String) {
        guard !isoMessage.isEmpty else {
            print("The isoMessage cannot be nil.")
            return nil
        }
        
        if isoMessage.prefix(3) == "ISO" {
            print("The ISO header is present. Please use the 'initWithIsoMessageAndHeader' method to build the ISOMessage.")
            return nil
        }
        
        self.init()
        
        setMTI(String(isoMessage.prefix(4)))
        let bitmapFirstBit = String(isoMessage.dropFirst(4).prefix(1))
        hasSecondaryBitmap = ["8", "9", "A", "B", "C", "D", "E", "F"].contains(bitmapFirstBit)
        
        bitmap = hasSecondaryBitmap
            ? Bitmap(hexString: String(isoMessage.dropFirst(4).prefix(32)))
            : Bitmap(hexString: String(isoMessage.dropFirst(4).prefix(16)))
        
        guard let bitmap = bitmap else {
            return nil
        }
        
        let dataElementValues = hasSecondaryBitmap ? isoMessage.dropFirst(36) : isoMessage.dropFirst(20)
        let theValues = extractDataElementValues(from: String(dataElementValues), withDataElements: bitmap.dataElementsInBitmap())
        
        bitmap.dataElementsInBitmap().enumerated().dropFirst().forEach { index, dataElement in
            addDataElement(dataElement, withValue: theValues[index - 1])
        }
    }
    
    /// Sets the MTI.
    /// - Parameter mti: The MTI for the message.
    mutating func setMTI(_ mti: String) {
        if isMTIValid(mti) {
            self.mti = mti
        } else {
            print("The MTI is not valid. Please set a valid MTI like the ones described in the isoMTI.plist or your custom MTI configuration file.")
        }
    }
    
    /// Add a new data element to the message.
    /// - Parameters:
    ///   - elementName: The data element name.
    ///   - value: The data element value.
    ///   - configFileName: The config file name for custom ISO-8583 messages.
    mutating func addDataElement(_ elementName: String, withValue value: String, configFileName: String? = nil) {
        guard let bitmap = bitmap else {
            print("Cannot add data elements without setting the bitmap before.")
            return
        }
        
        guard !elementName.isEmpty, !value.isEmpty else {
            print("Cannot add data elements with a nil name or value.")
            return
        }
        
        let binaryBitmap = bitmap.binaryBitmap
        let dataElementNumber = elementName.count == 4 ? String(elementName.suffix(2)) : String(elementName.suffix(3))
        
        guard let dataElementIndex = Int(dataElementNumber), dataElementIndex - 1 < binaryBitmap.count else {
            return
        }
        
        if dataElementIndex > 63 && !bitmap.hasSecondaryBitmap {
            print("Cannot add \(elementName) because a secondary bitmap is not declared.")
            return
        }
        
        if binaryBitmap[dataElementIndex - 1] != "1" {
            print("Cannot add \(elementName) because it is not declared in the bitmap.")
            return
        }
        
        guard let type = dataElementsScheme?.value(forKeyPath: "\(elementName).Type") as? String,
              let length = dataElementsScheme?.value(forKeyPath: "\(elementName).Length") as? String else {
            return
        }
        
        guard let dataElement = DataElement(name: elementName, value: value, dataType: type, length: length, customConfigFileName: configFileName) else {
            return
        }
        
        dataElements[elementName] = dataElement
    }
    
    /// Extracts data element values as an array of strings.
    /// - Parameters:
    ///   - isoMessageDataElementValues: The values as a string.
    ///   - dataElements: The data elements.
    /// - Returns: Data element values.
    func extractDataElementValues(from isoMessageDataElementValues: String, withDataElements dataElements: [String]) -> [String] {
        var values: [String] = []
        var fromIndex = 0
        
        dataElements.forEach { dataElement in
            guard dataElement != "DE01" else {
                return
            }
            
            guard let length = dataElementsScheme?.value(forKeyPath: "\(dataElement).Length") as? String else {
                return
            }
            
            if !length.contains(".") {
                let trueLength = Int(length) ?? 0
                let toIndex = fromIndex + trueLength
                let startIndex = isoMessageDataElementValues.index(isoMessageDataElementValues.startIndex, offsetBy: fromIndex)
                let endIndex = isoMessageDataElementValues.index(startIndex, offsetBy: trueLength)
                let value = String(isoMessageDataElementValues[startIndex..<endIndex])
                values.append(value)
                fromIndex = toIndex
            } else {
                let numberOfLengthDigits = length.count / 2
                let startIndexLength = isoMessageDataElementValues.index(isoMessageDataElementValues.startIndex, offsetBy: fromIndex)
                let endIndexLength = isoMessageDataElementValues.index(startIndexLength, offsetBy: numberOfLengthDigits)
                let trueLength = (Int(isoMessageDataElementValues[startIndexLength..<endIndexLength]) ?? 0) + numberOfLengthDigits
                let toIndex = fromIndex + trueLength
                let startIndexValue = isoMessageDataElementValues.index(isoMessageDataElementValues.startIndex, offsetBy: fromIndex + numberOfLengthDigits)
                let endIndexValue = isoMessageDataElementValues.index(startIndexValue, offsetBy: toIndex - (fromIndex + numberOfLengthDigits))
                let value = String(isoMessageDataElementValues[startIndexValue..<endIndexValue])
                values.append(value)
                fromIndex = toIndex
            }
        }
        
        return values
    }
    
    /// Determines if an MTI is valid
    /// - Parameter mti: The MTI.
    /// - Returns: `true` if valid.
    func isMTIValid(_ mti: String) -> Bool {
        return validMTIs.contains(mti)
    }
    
    /// Builds the ISO-8583 message as a string.
    /// - Returns: The string representation of the message.
    func buildIsoMessage() -> String? {
        guard let bitmap = bitmap, !dataElements.isEmpty, let mti = mti else {
            print("The bitmap, data elements, or MTI are missing.")
            return nil
        }
        
        let isoMessage = bitmap.dataElementsInBitmap().filter { $0 != "DE01" }.compactMap { dataElement -> String? in
            return dataElements[dataElement]?.value
        }.reduce(mti + bitmap.bitmapAsHexString(), +)
        
        return isoMessage
    }
    
    /// Appends the ISO header to the message.
    /// - Returns: A formatted message string prefixed with ISO.
    func buildIsoMessageWithISOHeader() -> String? {
        guard let isoMessage = buildIsoMessage() else {
            return nil
        }
        return "ISO" + isoMessage
    }
}

