import SwiftUI

class Suggestor {

    /*private*/ var ict: ICT

    init(_ ict: ICT) {
        self.ict = ict
    }

    func suggestion(_ situation: Situation) -> Suggestion {
        let hour = Calendar.current.component(.hour, from: situation.timestamp)
        let suggestion = ict.suggestions[hour]
        return suggestion!
    }

    func suggestCarbosForBloodglucose(_ situation: Situation) -> Double {
        ((ict.factors.carbosByDirection[situation.glucoseEntry.direction] ?? 1.0)
                *
                max(0, ict.limits.bloodglucose.min - Double(situation.glucoseEntry.glucose))) / suggestion(situation).bloodglucosePerCarbo
    }

    func suggestIeForBloodglucose(_ situation: Situation) -> Double {
        // TODO: take carbos and insulin of past last four hours into account
        max(0, situation.carbos - suggestCarbosForBloodglucose(situation)) * suggestion(situation).iePerCarbo
    }

    func suggestIeForCarbo(_ situation: Situation) -> Double {
        max(0, Double(situation.glucoseEntry.glucose) - ict.limits.bloodglucose.max) / suggestion(situation).bloodglucosePerIe
    }

}

struct EventView: View {

    @Environment(\.dismiss) var dismiss

    @State private var glucoseEntry: GlucoseEntry!

    @State private var carbos: Double = 0
    @State private var bolus: Double = 0
    @State private var base: Double = 0
    @State private var activityIntensity = 2
    @State private var activityTime: Double = 0

    @State private var timestamp = Date.now

    @State private var suggestor: Suggestor?

    func glucoseEntryAsText(_ glucoseEntry: GlucoseEntry) -> String {
        "\(glucoseEntry.glucoseAsText()) \(glucoseEntry.unitAsText()) \(glucoseEntry.directionAsText())"
    }

    func glucoseEntryAsText() -> String {
        if (glucoseEntry == nil) {
            return ""
        } else {
            return " (\(glucoseEntryAsText(glucoseEntry)))"
        }
    }

    func timestampAsText() -> String {
        timestamp.formatted(
                date: .abbreviated,
                time: .shortened)
                + glucoseEntryAsText()
    }

    func situation() -> Situation {
        Situation(
                timestamp: timestamp,
                glucoseEntry: glucoseEntry,
                carbos: carbos
        )
    }

    func suggestBolus() -> Double {
        let situation = situation()
        let suggestIeForCarbo = suggestor!.suggestIeForCarbo(situation) + suggestor!.suggestIeForBloodglucose(situation)
        return suggestIeForCarbo
    }

    func suggestCarbos() -> Double {
        let situation = situation()
        let suggestCarbosForBloodglucose = suggestor!.suggestCarbosForBloodglucose(situation)
        return suggestCarbosForBloodglucose
    }

    func glucoseEntryButton(_ newGlucoseEntry: GlucoseEntry) -> some View {
        Button(glucoseEntryAsText(newGlucoseEntry)) {
            self.glucoseEntry = newGlucoseEntry
        }
                .font(.system(size: 20))
                .fontWidth(.compressed)
                .background(newGlucoseEntry.glucoseAsColor().0)
                .foregroundColor(newGlucoseEntry.glucoseAsColor().1)
                .cornerRadius(4)
                .buttonStyle(BorderlessButtonStyle()) // WTF!!!
    }

    func debug() -> some View {
        let situation = situation()
        let suggestion = suggestor!.suggestion(situation)
        let suggestIeForCarbo = suggestor!.suggestIeForCarbo(situation)
        let suggestIeForBloodglucose = suggestor!.suggestIeForBloodglucose(situation)
        let suggestCarbosForBloodglucose = suggestor!.suggestCarbosForBloodglucose(situation)
        return VStack {
            Text("Suggestion: \(String(describing:suggestion)), \(suggestor!.ict.limits.bloodglucose.min, specifier: "%.f")..\(suggestor!.ict.limits.bloodglucose.max, specifier: "%.f") \nBolus: \(suggestBolus(), specifier: "%.2f") = \(suggestIeForCarbo, specifier: "%.2f") carbo + \(suggestIeForBloodglucose, specifier: "%.2f") bloodglucose\nCarbos: \(suggestCarbosForBloodglucose, specifier: "%.2f")")
                    .font(.system(size: 12))
            HStack {
                Button("loadict") {
                    ictEventAPI.fetchIct() { a, b in
                        // print(a)
                        // print(b)
                    }
                }
                        .buttonStyle(BorderlessButtonStyle()) // WTF!!!
                Button("storeict") {
                    ictEventAPI.storeIct(suggestor!.ict)
                }
                        .buttonStyle(BorderlessButtonStyle()) // WTF!!!
                /*Button("handleAppear() ") {
                 handleAppear()
                 }*/
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 230,
                        unit: .mgDl,
                        direction: .rapidlyIncreasing,
                        location: .high
                ))
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 230,
                        unit: .mgDl,
                        direction: .increasing,
                        location: .high
                ))
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 230,
                        unit: .mgDl,
                        direction: .steady,
                        location: .high
                ))
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 230,
                        unit: .mgDl,
                        direction: .decreasing,
                        location: .high
                ))
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 230,
                        unit: .mgDl,
                        direction: .rapidlyDecreasing,
                        location: .high
                ))
            }
            HStack {
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 50,
                        unit: .mgDl,
                        direction: .rapidlyIncreasing,
                        location: .high
                ))
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 50,
                        unit: .mgDl,
                        direction: .increasing,
                        location: .high
                ))
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 50,
                        unit: .mgDl,
                        direction: .steady,
                        location: .high
                ))
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 50,
                        unit: .mgDl,
                        direction: .decreasing,
                        location: .high
                ))
                glucoseEntryButton(SimpleGlucoseEntry(
                        date: Date.now,
                        glucose: 50,
                        unit: .mgDl,
                        direction: .rapidlyDecreasing,
                        location: .high
                ))
            }
        }
    }

    private func minMaxSlider(value: Binding<Double>, minMax: MinMax) -> some View {
        Slider(value: value, in: minMax.min...minMax.max, step: minMax.step)
    }

    private func suggestCarbosText() -> Text {
        let suggestedCarbos = suggestCarbos()

        return if suggestedCarbos > 0 {
            Text(Strings.suggestCarbos.replacingOccurrences(of: "{suggestedCarbos}", with: String(format: "%.2f", suggestedCarbos)))
                .foregroundColor(.lwOrange)
        } else {
            Text(Strings.correctionUnnecessary)
        }
    }

    private func suggestBolusText() -> Text {
        let suggestedBolus = suggestBolus()

        return if suggestedBolus > 0 {
            Text(Strings.suggestBolus.replacingOccurrences(of: "{suggestedBolus}", with: String(format: "%.2f", suggestedBolus)))
                .foregroundColor(.lwOrange)
        } else {
            Text(Strings.correctionUnnecessary)
        }
    }

    func editPane() -> some View {
        Form {
            Section(header: Text(Strings.carbos), footer: suggestCarbosText()) {
                VStack {
                    Text("\(carbos, specifier: "%.2f")")
                    minMaxSlider(value: $carbos, minMax: suggestor!.ict.limits.carbos)
                }
            }
            Section(header: Text(Strings.insulin), footer: suggestBolusText()) {
                VStack {
                    Text("\(bolus, specifier: "%.f") IE \(Strings.bolus)")
                    minMaxSlider(value: $bolus, minMax: suggestor!.ict.limits.bolus)
                }
                VStack {
                    Text("\(base, specifier: "%.f") IE \(Strings.base)")

                    minMaxSlider(value: $base, minMax: suggestor!.ict.limits.base)
                }
            }
            Section(header: Text(Strings.activity)) {
                VStack {
                    Text("\(activityTime, specifier: "%.f") \(Strings.minutes)")

                    minMaxSlider(value: $activityTime, minMax: suggestor!.ict.limits.activityTime)
                }
                VStack {
                    Picker("", selection: $activityIntensity, content: {
                        Text(Strings.low).tag(1)
                        Text(Strings.regular).tag(2)
                        Text(Strings.high).tag(3)
                    })
                            .pickerStyle(SegmentedPickerStyle())
                }
                        .disabled(activityTime == 0)
            }
            Section {
                Button(Strings.save) {
                    let event: IctEvent = IctEvent(
                            timestamp: Date.now,
                            glucose: Double(glucoseEntry.glucose),
                            direction: glucoseEntry.direction,
                            carbos: carbos,
                            bolus: bolus,
                            base: base,
                            activityIntensity: activityIntensity,
                            activityTime: activityTime
                    )
                    ictEventAPI.storeEvent(event)
                    dismiss()
                }
                        .disabled(carbos + bolus + base + activityTime == 0)
            }
            debug()
        }
        //.scrollContentBackground(.hidden)
    }

    func bgColor() -> Color {
        .lwGreen
    }

    func updateWithGlucoseItem(_ glucoseItem: GlucoseItem) {
        print("updateWithGlucoseItem")
        self.glucoseEntry = SimpleGlucoseEntry.fromGlucoseItem(glucoseItem)
    }

    func updateWithIct(_ ict: ICT) {
        print("updateWithIct")
        self.timestamp = Date.now
        self.suggestor = Suggestor(ict)
    }

    func handleAppear() {
        libreViewAPI.fetchCurrentGlucoseEntry { glucoseItem, error in
            if let glucoseItem = glucoseItem {
                updateWithGlucoseItem(glucoseItem)
                ictEventAPI.fetchIct { ict, error in
                    if let ict = ict {
                        updateWithIct(ict)
                    } else {
                        print("ERROR: fetchIct: \(error)")
                    }
                }
            } else {
                print("ERROR: fetchCurrentGlucoseEntry: \(error)")
            }
        }
    }

    func checkIct() -> String {
        if suggestor == nil {
            Strings.loading
        } else {
            ""
        }
    }

    var body: some View {
        if suggestor == nil {
            Text(checkIct()).onAppear {
                handleAppear()
            }
        } else {
            NavigationStack {
                        editPane()
                .navigationTitle(timestampAsText())
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(situation().glucoseEntry.glucoseAsColor().0,for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }
        }
    }

}

#Preview {
    EventView()
}
