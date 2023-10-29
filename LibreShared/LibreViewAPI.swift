import Foundation

struct AuthRequest: Encodable {
    let email: String
    let password: String
}

struct AuthTicket: Decodable {
    let duration: Int
    let expires: Int
    let token: String
}

struct AuthData: Decodable {
    let authTicket: AuthTicket?
}

struct AuthResponse: Decodable {
    let status: Int?
    let data: AuthData?
}

struct ConnectionData: Decodable {
    let glucoseItem: GlucoseItem?
}

struct GlucoseItem: Decodable {
    let timestamp: String?
    let valueInMgPerDL: Int?
    let trendArrow: Int?
    let measurementColor: Int?
    let value: Int?

    enum CodingKeys: String, CodingKey {
        case timestamp = "Timestamp"
        case valueInMgPerDL = "ValueInMgPerDl"
        case trendArrow = "TrendArrow"
        case measurementColor = "MeasurementColor"
        case value = "Value"
    }

    func isOutdated() -> Bool {
        if let timestamp = Date.enUS(from: timestamp ?? "") {
            return timestamp < Date().adding(minutes: -3)
        }
        return true
    }

    static let preview: GlucoseItem = GlucoseItem(
            timestamp: "8/20/2069 3:15:16 PM",
            valueInMgPerDL: 105,
            trendArrow: 3,
            measurementColor: 1,
            value: 105
    )

    static let unspecific: GlucoseItem = GlucoseItem(
            timestamp: "8/20/2069 3:15:16 PM",
            valueInMgPerDL: -1,
            trendArrow: -1,
            measurementColor: -1,
            value: -1
    )
}

struct ConnectionsResponse: Decodable {
    let status: Int
    let data: [ConnectionData]
    let ticket: AuthTicket
}

struct FetchStatus {
    static let FAILED = 2
    static let LOCKED = 429
}

protocol LibreViewAPI {
    func resetAuthentication()
    func fetchCurrentGlucoseEntry(completion: @escaping (GlucoseItem?, Any?) -> ())
}

class DemoLibreViewAPI: LibreViewAPI {
    func resetAuthentication() {
    }

    func fetchCurrentGlucoseEntry(completion: @escaping (GlucoseItem?, Any?) -> ()) {
        if (appConfiguration.password == "x") {
            completion(nil, "Error")
        } else {
            completion(GlucoseItem.preview, nil)
        }
    }
}

struct AccessToken {
    let token: String
    let expiresAt: Date

    var isExpired: Bool {
        expiresAt.timeIntervalSinceNow.sign == .minus
    }

    static let Empty = AccessToken(token: "", expiresAt: Date.distantPast)
}

class DefaultLibreViewAPI: LibreViewAPI {

    private var server = "https://api.libreview.io"
    private var accessToken = AccessToken.Empty

    func resetAuthentication() {
        accessToken = AccessToken.Empty
    }

    private func defaultRequest(_ path: String) -> URLRequest {
        guard let url = URL(string: "\(server)\(path)") else {
            fatalError("Missing URL")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 15
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("4.7.0", forHTTPHeaderField: "version")
        urlRequest.addValue("llu.ios", forHTTPHeaderField: "product")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }

    private func fetchRequest() -> URLRequest {
        var urlRequest = defaultRequest("/llu/connections")
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(accessToken.token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }

    private func fetchCurrentGlucoseEntryAuthorized(completion: @escaping (GlucoseItem?, Any?) -> ()) {
        URLSession.shared.dataTask(with: fetchRequest()) { (data, response, error) in
                      if let data = data {
                          do {
                              let response = try JSONDecoder().decode(ConnectionsResponse.self, from: data)
                              if let glucoseItem = response.data.first?.glucoseItem {
                                  completion(glucoseItem, nil)
                              } else {
                                  completion(nil, "No glucose item found in response.")
                              }
                          } catch {
                              completion(nil, error)
                          }
                      } else if let error = error {
                          completion(nil, error)
                      }
                  }
                  .resume()
    }

    private func authorizationRequest() -> URLRequest {
        var urlRequest = defaultRequest("/llu/auth/login")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = authorizationRequestData()
        return urlRequest
    }

    private func authorizationRequestData() -> Data {
        let authenticationRequest = AuthRequest(email: appConfiguration.username, password: appConfiguration.password)
        return try! JSONEncoder().encode(authenticationRequest)
    }

    private func fetchCurrentGlucoseEntryUnauthorized(completion: @escaping (GlucoseItem?, Any?) -> ()) {
        URLSession.shared.dataTask(with: authorizationRequest()) { (data, response, error) in
                      if let data = data {
                          do {
                              let response = try JSONDecoder().decode(AuthResponse.self, from: data)
                              // TODO check status
                              if let authTicket = response.data?.authTicket {
                                  self.accessToken = AccessToken(token: authTicket.token, expiresAt: Date(timeIntervalSince1970: TimeInterval(authTicket.expires)))
                                  self.fetchCurrentGlucoseEntryAuthorized(completion: completion)
                              } else {
                                  completion(nil, response.status)
                              }
                          } catch {
                              completion(nil, error)
                          }
                      } else if let error = error {
                          completion(nil, error)
                      }
                  }
                  .resume()
    }

    func fetchCurrentGlucoseEntry(completion: @escaping (GlucoseItem?, Any?) -> ()) {
        if (accessToken.isExpired) {
            if (appConfiguration.connected == .locked) {
                completion(nil, FetchStatus.FAILED)
            }
            fetchCurrentGlucoseEntryUnauthorized(completion: completion)
        } else {
            fetchCurrentGlucoseEntryAuthorized(completion: completion)
        }
    }
}

let libreViewAPI: LibreViewAPI = DEMO
                                 ? DemoLibreViewAPI()
                                 : DefaultLibreViewAPI()
