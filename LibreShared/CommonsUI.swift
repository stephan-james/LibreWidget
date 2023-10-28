import SwiftUI

extension Color {

    private static func percented(_ absoluteValue: Int) -> Double {
        Double(absoluteValue) / 255
    }

    static func rgb(red: Int, green: Int, blue: Int) -> Color {
        Color(red: percented(red), green: percented(green), blue: percented(blue))
    }

    static let lwGreen = Color.rgb(red: 145, green: 203, blue: 49)
    static let lwYellow = Color.rgb(red: 255, green: 187, blue: 0)
    static let lwOrange = Color.rgb(red: 238, green: 107, blue: 3)
    static let lwRed = Color.rgb(red: 236, green: 29, blue: 34)
    static let lwUnknown = Color.rgb(red: 222, green: 222, blue: 222)

}

extension Font {

    static let customFont = Font(UIFont(name: "Brygada1918Italic-SemiBold", size: 36)!)

}
