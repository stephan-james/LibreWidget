import Foundation

extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.stephanjames")!
}

enum Connection: Int {
    case disconnected = 0
    case connected = 1
    case connecting = 2
    case failed = -1
    case locked = -2
}

class AppConfiguration: ObservableObject {

    private let keyAuthorizationGranted = "authorizationGranted"
    private let keyUsername = "username"
    private let keyPassword = "password"
    private let keyConnection = "connection"
    private let keyLockTime = "lockTime"

    var authorizationGranted: Bool {
        set {
            UserDefaults.group.set(newValue, forKey: keyAuthorizationGranted)
        }
        get {
            UserDefaults.group.bool(forKey: keyAuthorizationGranted)
        }
    }

    var username: String {
        set {
            UserDefaults.group.set(newValue, forKey: keyUsername)
        }
        get {
            UserDefaults.group.string(forKey: keyUsername) ?? ""
        }
    }

    var password: String {
        set {
            UserDefaults.group.set(newValue, forKey: keyPassword)
        }
        get {
            UserDefaults.group.string(forKey: keyPassword) ?? ""
        }
    }

    var connected: Connection {
        set {
            if connected != .locked && newValue == .locked {
                lockTime = Date()
            }
            UserDefaults.group.set(newValue.rawValue, forKey: keyConnection)
        }
        get {
            let value = Connection(rawValue: UserDefaults.group.integer(forKey: keyConnection)) ?? .disconnected
            if value == .locked && lockTime.adding(minutes: +5) < Date() {
                return .disconnected
            }
            return value
        }
    }

    fileprivate var lockTime: Date {
        set {
            UserDefaults.group.set(newValue, forKey: keyLockTime)
        }
        get {
            UserDefaults.group.object(forKey: keyLockTime) as? Date ?? Date.distantPast
        }
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: AppConfiguration) {
        appendLiteral("\(value.username), \(value.password), \(value.connected), \(value.lockTime)")
    }
}

var appConfiguration = AppConfiguration()
