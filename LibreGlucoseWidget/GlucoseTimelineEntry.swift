import Foundation
import WidgetKit

struct GlucoseTimelineEntry: TimelineEntry, GlucoseEntry {
    let date: Date
    let glucose: Float
    let unit: Unit
    let direction: Direction
    let location: Location

    let configuration: ConfigurationIntent

    static func defaultEntry() -> GlucoseTimelineEntry {
        GlucoseTimelineEntry(date: Date(), glucose: 105, unit: .mgDl, direction: Direction.steady, location: .regular, configuration: ConfigurationIntent())
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: GlucoseTimelineEntry) {
        appendLiteral("date=\(value.date), glucose=\(value.glucose), unit=\(value.unit), direction=\(value.direction), location=\(value.location)")
    }
}
