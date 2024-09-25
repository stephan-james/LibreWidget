import SwiftUI

enum Direction: String, Codable {
    case rapidlyIncreasing, increasing, steady, decreasing, rapidlyDecreasing, unknown

    static func byTrendArrow(_ trendArrow: Int) -> Direction {
        switch trendArrow {
        case 5:
            return .rapidlyIncreasing
        case 4:
            return .increasing
        case 3:
            return .steady
        case 2:
            return .decreasing
        case 1:
            return .rapidlyDecreasing
        default:
            return .unknown
        }
    }
}

enum Location {
    case high, regular, outranged, low, unknown

    static func byMeasurementColor(_ measurementColor: Int) -> Location {
        switch measurementColor {
        case 1:
            return .regular
        case 2:
            return .outranged
        case 3:
            return .high
        case 4:
            return .low
        default:
            return .unknown
        }
    }
}

enum Unit {
    case mgDl, mmol
}

protocol GlucoseEntry {
    var date: Date { get }
    var glucose: Float { get }
    var unit: Unit { get }
    var direction: Direction { get }
    var location: Location { get }
}

struct SimpleGlucoseEntry : GlucoseEntry {
    let date: Date
    let glucose: Float
    let unit: Unit
    let direction: Direction
    let location: Location

    static func fromGlucoseItem(_ glucoseItem: GlucoseItem) -> GlucoseEntry {
        SimpleGlucoseEntry( // date: Calendar.current.date(byAdding: .minute, value: minuteOffset, to: Date())!,
            date: Date.now, // TODO
                           glucose: Float(glucoseItem.value ?? GlucoseItem.unspecific.value!),
                           unit: glucoseItem.value == glucoseItem.valueInMgPerDL ? .mgDl : .mmol,
                           direction: Direction.byTrendArrow(glucoseItem.trendArrow ?? GlucoseItem.unspecific.trendArrow!),
                           location: Location.byMeasurementColor(glucoseItem.measurementColor ?? GlucoseItem.unspecific.measurementColor!))
    }

}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: GlucoseEntry) {
        appendLiteral("date=\(value.date), glucose=\(value.glucose), unit=\(value.unit), direction=\(value.direction), location=\(value.location)")
    }
}




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



extension GlucoseEntry {

    func glucoseAsText() -> String {
        if self.glucose <= 0 {
            return "--"
        } else if self.unit == .mgDl {
            return "\(Int(self.glucose))"
        } else {
            return String(format: "%.1f", self.glucose)
        }
    }

    func directionAsText() -> String {
        if self.glucose == 0 {
            return ""
        }
        switch self.direction {
        case .rapidlyIncreasing:
            return "↑"
        case .increasing:
            return "↗"
        case .steady:
            return "→"
        case .decreasing:
            return "↘"
        case .rapidlyDecreasing:
            return "↓"
        case .unknown:
            return ""
        }
    }

    func glucoseAsColor() -> (Color, Color) {
        if self.glucose == 0 {
            return (.lwUnknown, .black)
        }
        switch self.location {
        case .regular:
            return (.lwGreen, .black)
        case .outranged:
            return (.lwYellow, .black)
        case .high:
            return (.lwOrange, .white)
        case .low:
            return (.lwRed, .white)
        default:
            return (.lwUnknown, .black)
        }
    }

    func unitAsText() -> String {
        switch self.unit {
        case .mgDl:
            return "mg/dL"
        case .mmol:
            return "mmol"
        }
    }

}
