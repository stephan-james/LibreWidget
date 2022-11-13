import Foundation

extension String {

    var isBlank: Bool {
        allSatisfy({ $0.isWhitespace })
    }

    var attributed: AttributedString {
        try! AttributedString(markdown: self)
    }

}

extension Date {

    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func localizedTime() -> String {
        let formatter = DateFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    static func enUS(from value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm:ss a"
        return formatter.date(from: value)
    }

}
