import Foundation
import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {

    func placeholder(in context: Context) -> GlucoseEntry {
        GlucoseEntry.defaultEntry()
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (GlucoseEntry) -> ()) {
        completion(GlucoseEntry.defaultEntry())
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        if context.isPreview {
            completion(createTimeline(glucoseItem: GlucoseItem.preview, configuration: configuration))
        } else if appConfiguration.connected != .connected {
            completion(createTimeline(glucoseItem: GlucoseItem.unspecific, configuration: configuration))
        } else {
            libreViewAPI.fetchCurrentGlucoseEntry { glucoseItem, error in
                if let gi = glucoseItem {
                    let timeline = createTimeline(glucoseItem: gi, configuration: configuration)
                    completion(timeline)
                }
            }
        }
    }

    private func createTimeline(glucoseItem: GlucoseItem, configuration: ConfigurationIntent) -> Timeline<GlucoseEntry> {
        guard !glucoseItem.isOutdated() else {
            return createTimeline(glucoseItem: GlucoseItem.unspecific, configuration: configuration)
        }
        let entries = [0, 1, 2].map { minuteOffset in
            GlucoseEntry(
                    date: Calendar.current.date(byAdding: .minute, value: minuteOffset, to: Date())!,
                    glucose: Float(glucoseItem.value ?? GlucoseItem.unspecific.value!),
                    unit: glucoseItem.value == glucoseItem.valueInMgPerDL ? .mgDl : .mmol,
                    direction: Direction.byTrendArrow(glucoseItem.trendArrow ?? GlucoseItem.unspecific.trendArrow!),
                    location: Location.byMeasurementColor(glucoseItem.measurementColor ?? GlucoseItem.unspecific.measurementColor!),
                    configuration: configuration)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct LibreGlucoseWidgetEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) private var family

    var direction: String {
        if entry.glucose == 0 {
            return ""
        }
        switch entry.direction {
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

    var glucose: String {
        if entry.glucose <= 0 {
            return "--"
        } else if entry.unit == .mgDl {
            return "\(Int(entry.glucose))"
        } else {
            return String(format: "%.1f", entry.glucose)
        }
    }

    var color: (Color, Color) {
        if entry.glucose == 0 {
            return (.lwUnknown, .black)
        }
        switch entry.location {
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

    @ViewBuilder
    var body: some View {
        switch family {
            case .systemSmall:
                ZStack {
                    color.0
                    VStack(alignment: .center, spacing: -6) {
                        Text(verbatim: direction)
                                .font(.system(size: 48, weight: .heavy, design: .monospaced))
                                .foregroundColor(color.1)
                        Text(verbatim: glucose)
                                .font(.system(size: 52, weight: .heavy))
                                .foregroundColor(color.1)
                    }
                }
            case .accessoryCircular:
                ZStack(alignment: .center) {
                    Color(.white)
                    VStack(alignment: .center, spacing: -6) {
                        Text(verbatim: direction)
                                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                                .colorInvert()
                        Text(verbatim: glucose)
                                .font(.system(size: 20, weight: .heavy))
                                .colorInvert()
                        Text(verbatim: " ")
                                .font(.system(size: 10, weight: .heavy))
                                .colorInvert()
                    }
                }
            default:
                VStack(alignment: .center) {
                    Text("username=\(appConfiguration.username)")
                    Text("\(appConfiguration.connected)" as String)
                    Text("\(entry)" as String)
                            .font(.system(size: 10))
                    Text("\(entry.date.localizedTime())")
                            .font(.system(size: 10))
                    ZStack {
                        Color.lwOrange
                        Text("ORANGE")
                    }
                    ZStack {
                        Color.lwYellow
                        Text("YELLOW")
                    }
                    ZStack {
                        Color.lwGreen
                        Text("GREEN")
                    }
                    ZStack {
                        Color.lwRed
                        Text("RED")
                    }
                    ZStack {
                        Color.lwUnknown
                        Text("UNKNOWN")
                    }
                }
        }
    }
}

@main
struct LibreGlucoseWidget: Widget {

    var body: some WidgetConfiguration {
        IntentConfiguration(
                kind: "LibreGlucoseWidget",
                intent: ConfigurationIntent.self,
                provider: Provider()) { entry in
            LibreGlucoseWidgetEntryView(entry: entry)
        }.supportedFamilies([.accessoryCircular, .systemSmall] +
                            (DEMO ? [.systemExtraLarge, .systemLarge, .systemMedium] : []))
         .configurationDisplayName("Libre Glucose Widget")
         .description("This is a personal widget.")
    }
}

struct LibreGlucoseWidget_Previews: PreviewProvider {

    static func exampleEntry(location: Location) -> GlucoseEntry {
        GlucoseEntry(date: Date(), glucose: 185, unit: .mgDl, direction: Direction.steady, location: location, configuration: ConfigurationIntent())
    }

    static var previews: some View {
        Group {
            LibreGlucoseWidgetEntryView(entry: exampleEntry(location: .regular))
                    .previewContext(WidgetPreviewContext(family: .systemSmall))
                    .previewDisplayName("systemSmall:1")
            LibreGlucoseWidgetEntryView(entry: exampleEntry(location: .low))
                    .previewContext(WidgetPreviewContext(family: .systemSmall))
                    .previewDisplayName("systemSmall:2")
            LibreGlucoseWidgetEntryView(entry: exampleEntry(location: .high))
                    .previewContext(WidgetPreviewContext(family: .systemSmall))
                    .previewDisplayName("systemSmall:3")
            LibreGlucoseWidgetEntryView(entry: exampleEntry(location: .outranged))
                    .previewContext(WidgetPreviewContext(family: .systemSmall))
                    .previewDisplayName("systemSmall:4")
            LibreGlucoseWidgetEntryView(entry: exampleEntry(location: .regular))
                    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
                    .previewDisplayName("systemExtraLarge")
            LibreGlucoseWidgetEntryView(entry: exampleEntry(location: .low))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                    .previewDisplayName("accessoryCircular")
        }
    }
}
