import Foundation

/*
 create these databases in couch db
 PUT /_users
 PUT /_replicator
 PUT /_global_changes
 */

struct Suggestion: Encodable, Decodable {
    var iePerCarbo: Double
    var bloodglucosePerCarbo: Double
    var bloodglucosePerIe: Double
}

struct Situation {
    var timestamp: Date
    var glucoseEntry: GlucoseEntry
    var carbos: Double
}

struct MinMax: Encodable, Decodable {
    var min: Double
    var max: Double
    var step: Double = 0
}

struct Limits: Encodable, Decodable {
    var bloodglucose: MinMax
    var carbos: MinMax
    var bolus: MinMax
    var base: MinMax
    var activityTime: MinMax
}

struct Factors: Encodable, Decodable {
    var carbosByDirection: [Direction: Double]
    var bolusByDirection: [Direction: Double]
}

struct ICT: Encodable, Decodable {
    var limits: Limits
    var factors: Factors
    var suggestions: [Int: Suggestion]
}


struct IctEvent: Encodable {
    let timestamp: Date
    let glucose: Double
    let direction: Direction
    let carbos: Double
    let bolus: Double
    let base: Double
    let activityIntensity: Int
    let activityTime: Double
}

protocol IctEventAPI {
    func storeEvent(_ event: IctEvent)
    func storeIct(_ ict: ICT)
    func fetchIct(completion: @escaping (ICT?, Any?) -> ())
}

class DemoIctEventAPI: IctEventAPI {

    func storeEvent(_ event: IctEvent) {
        print("storeEvent \(event)")
    }

    func storeIct(_ ict: ICT) {
    }

    func fetchIct(completion: @escaping (ICT?, Any?) -> ()) {
        completion(ICT(
                limits: Limits(
                        bloodglucose: MinMax(
                                min: 80,
                                max: 140),
                        carbos: MinMax(min: 0, max: 12, step: 0.25),
                        bolus: MinMax(min: 0, max: 12, step: 1),
                        base: MinMax(min: 0, max: 10, step: 1),
                        activityTime: MinMax(min: 0, max: 180, step: 5)),
                factors: Factors(
                    carbosByDirection: [
                        .rapidlyDecreasing: 1.0,
                        .decreasing: 1.0,
                        .steady: 1.0,
                        .unknown: 1.0,
                        .increasing: 1.0,
                        .rapidlyIncreasing: 1.0],
                    bolusByDirection: [
                        .rapidlyDecreasing: 1.0,
                        .decreasing: 1.0,
                        .steady: 1.0,
                        .unknown: 1.0,
                        .increasing: 1.0,
                        .rapidlyIncreasing: 1.0]
                ),
                suggestions: [
                    0: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    1: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    2: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    3: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    4: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    5: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    6: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    7: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    8: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    9: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    10: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    11: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    12: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    13: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    14: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    15: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    16: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    17: Suggestion(iePerCarbo: 1.2, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    18: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    19: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    20: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    21: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    22: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0),
                    23: Suggestion(iePerCarbo: 1.0, bloodglucosePerCarbo: 31.0, bloodglucosePerIe: 31.0)
                ]), nil)
    }

}

struct IctEventAPIConfiguration {
    var url: String
    var database: String
    var username: String
    var password: String
}

let ictEventAPIConfigurationLocal = IctEventAPIConfiguration(
        url: "http://silicon.fritz.box:5984",
        database: "events",
        username: "cdbuser",
        password: "cdbpassword"
)

let ictEventAPIConfigurationFovea = IctEventAPIConfiguration(
        url: "https://couche-db",
        database: "events",
        username: "***",
        password: "***"
)

let ictEventAPIConfiguration = ictEventAPIConfigurationFovea

class DefaultIctEventAPI: IctEventAPI {

    func fetchIct(completion: @escaping (ICT?, Any?) -> ()) {
        let decoder = buildDecoder()
        URLSession.shared.dataTask(with: buildBaseRequest(path: "settings/ict")) { (data, response, error) in
                    if let data = data {
                        do {
                            print(data)
                            let response = try decoder.decode(ICT.self, from: data)
                            print(response)
                            completion(response, nil)
                        } catch {
                            completion(nil, error)
                        }
                    } else if let error = error {
                        completion(nil, error)
                    }
                }
                .resume()
    }

    func storeIct(_ ict: ICT) {
        var request = buildBaseRequest(path: "settings/ict-test-only")
        request.httpMethod = "PUT"
        request.httpBody = try! buildEncoder().encode(ict)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if response.statusCode == 201 {
                print("PUT request successful")
            } else {
                print("Error: HTTP \(response.statusCode)")
            }
        }.resume()
    }

    func storeEvent(_ event: IctEvent) {
        let request = buildNewEventRequest(event: event)
        URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                        print("Error: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    if response.statusCode == 201 {
                        print("PUT request successful")
                    } else {
                        print("Error: HTTP \(response.statusCode)")
                    }
                }
                .resume()
    }

    private func buildNewEventRequest(event: IctEvent) -> URLRequest {
        var request = buildBaseRequest(path: buildNewEventPath())
        request.httpMethod = "PUT"
        request.httpBody = try! buildEncoder().encode(event)
        return request
    }

    private func buildBaseRequest(path: String) -> URLRequest {
        var request = URLRequest(url: buildUrl(path: path))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Basic \(buildAuthorization())", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }

    private func buildAuthorization() -> String {
        let loginData = "\(ictEventAPIConfiguration.username):\(ictEventAPIConfiguration.password)".data(using: .utf8)!
        return loginData.base64EncodedString()

    }

    private func buildEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(buildJsonDateFormatter())
        return encoder
    }

    private func buildDecoder() -> JSONDecoder {
        let encoder = JSONDecoder()
        encoder.dateDecodingStrategy = .formatted(buildJsonDateFormatter())
        return encoder
    }

    private func buildJsonDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }

    private func buildNewEventPath() -> String {
        return "\(ictEventAPIConfiguration.database)/\(buildEventId())"
    }

    private func buildUrl(path: String) -> URL {
        URL(string: "\(ictEventAPIConfiguration.url)/\(path)")!
    }

    private func buildEventId() -> String {
        let dateFormatterId = DateFormatter()
        dateFormatterId.dateFormat = "yyyy-MM-dd_HH-mm-ss-mmm"
        return dateFormatterId.string(from: Date.now)
    }

}

let ictEventAPI: IctEventAPI = DEMO_ICT
        ? DemoIctEventAPI()
        : DefaultIctEventAPI()
