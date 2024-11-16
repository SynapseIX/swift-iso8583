Swift-ISO8583
=================

Swift library for iOS, iPadOS, macOS, tvOS, watchOS, and visionOS that implements the ISO-8583 financial transaction protocol. Build and parse ISO-8583 messages using a friendly and easy to use interface.

Currently supports protocol version ISO 8583-1:1987.

To use the package, add it as a dependency via Swift Package Manager.

Be sure to contact me for help using the library, and of course, report any issues/bugs you find.
The ability to build your own custom ISO8583-formatted messages is still under consideration.

Example of usage 1
--------------

```swift
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
```
	
Example of usage 2
--------------

```swift
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
```

More examples of usage are included in the tests.
