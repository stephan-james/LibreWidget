import Foundation
import WidgetKit

enum Direction {
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

struct GlucoseEntry: TimelineEntry {
    let date: Date
    let glucose: Float
    let unit: Unit
    let direction: Direction
    let location: Location

    let configuration: ConfigurationIntent

    static func defaultEntry() -> GlucoseEntry {
        GlucoseEntry(date: Date(), glucose: 105, unit: .mgDl, direction: Direction.steady, location: .regular, configuration: ConfigurationIntent())
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: GlucoseEntry) {
        appendLiteral("date=\(value.date), glucose=\(value.glucose), unit=\(value.unit), direction=\(value.direction), location=\(value.location)")
    }
}
