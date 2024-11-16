import Testing
@testable import Swift_ISO8583

@Test func example1() async throws {
    print("***EXAMPLE OF USAGE #1***")
    
    // Initialize new instance and set MTI
    var isoMessage = ISOMessage()
    isoMessage.setMTI("0200")

    // Build the bitmap. In this case we also declare the presence
    // of a secondary bitmap and data elements: 3, 4, 7, 11, 44, 105
    isoMessage.bitmap = Bitmap(
        givenDataElements: ["DE03","DE04", "DE07", "DE11", "DE44", "DE105"]
    )
    
    // Add the declared data elements and their values
    isoMessage.addDataElement("DE03", withValue: "123")
    isoMessage.addDataElement("DE04", withValue: "123")
    isoMessage.addDataElement("DE07", withValue: "123")
    isoMessage.addDataElement("DE11", withValue: "123")
    isoMessage.addDataElement("DE44", withValue: "Value for DE44")
    isoMessage.addDataElement("DE105", withValue: "This is the value for DE105")
    
    guard let message = isoMessage.buildIsoMessage() else {
        return
    }
    
    print("Built message: \(message)")
    #expect(message == "0200B22000000010000000000000008000000001230000000001230000000123000123Value for DE44This is the value for DE105")
}

@Test func example2() async throws {
    print("***EXAMPLE OF USAGE #2***")
    
    // Initialize new instance and set MTI
    var isoMessage = ISOMessage()
    isoMessage.setMTI("0200")

    // Build the bitmap. In this case we also declare the presence
    // of a secondary bitmap and data elements: 3, 4, 7, 11, 44, 105 as HEX
    isoMessage.bitmap = Bitmap(hexString: "B2200000001000000000000000800000")
    
    // Add the declared data elements and their values
    isoMessage.addDataElement("DE03", withValue: "123")
    isoMessage.addDataElement("DE04", withValue: "123")
    isoMessage.addDataElement("DE07", withValue: "123")
    isoMessage.addDataElement("DE11", withValue: "123")
    isoMessage.addDataElement("DE44", withValue: "Value for DE44")
    isoMessage.addDataElement("DE105", withValue: "This is the value for DE105")
    
    guard let message = isoMessage.buildIsoMessage() else {
        return
    }
    
    print("Built message: \(message)")
    #expect(message == "0200B22000000010000000000000008000000001230000000001230000000123000123Value for DE44This is the value for DE105")
}

@Test func example3() async throws {
    print("***EXAMPLE OF USAGE #3***")
    
    let isoMessage = ISOMessage(isoMessage: "0200B2200000001000000000000000800000000123000000000123000000012300012314Value for DE44027This is the value for DE105")
    
    guard let dataElements = isoMessage?.dataElements else {
        #expect(Bool(false))
        return
    }
    
    let expectedDataElements = ["DE03", "DE04", "DE07", "DE11", "DE44", "DE105"]
    let currentDataElements = dataElements.map { $0.value.name }.sorted { $0.compare($1, options: .numeric) == .orderedAscending }
    
    print(currentDataElements)
    #expect(expectedDataElements == currentDataElements)
}



