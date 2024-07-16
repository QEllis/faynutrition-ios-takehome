//
//  Server.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import Foundation

class Server {

    static let shared = Server()

    private let baseURLString = "https://node-api-for-candidates.onrender.com"
    private var loginToken: String?
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df
    }()

    // POST
    private let signInExtension = "/signin"

    // GET
    private let fetchAppointmentExtension = "/appointments"

    init() {}

    /// completion returns Bool representing login success
    /// completion returns Error? based on result of login request. nil when login succeeds
    public func login(username: String, password: String, completion: @escaping (Bool, FayServerError?) -> ()) {
        guard let postUrl = URL(string: baseURLString + signInExtension) else {
            completion(false, FayServerError.invalidUrl)
            return
        }

        let message = LoginMessage(username: username, password: password)

        guard let data = try? JSONEncoder().encode(message) else {
            completion(false, FayServerError.invalidMessageData)
            return
        }

        var request = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse else {
                completion(false, FayServerError.invalidServerResponse)
                return
            }

            if httpURLResponse.statusCode == 200, let data {
                // Success
                guard let decoded = try? JSONDecoder().decode(LoginDataResponse.self, from: data) else {
                    completion(false, FayServerError.invalidServerResponse)
                    return
                }
                Server.shared.loginToken = decoded.token
                completion(true, nil)
            } else {
                // Failure
                completion(false, FayServerError.invalidCredentials)
            }
        }
        task.resume()
    }

    public func fetchAppointments(completion: @escaping ([Appointment], FayServerError?) -> ()) {
        guard let loginToken = loginToken else {
            completion([], FayServerError.notLoggedIn)
            return
        }

        guard let fetchUrl = URL(string: baseURLString + fetchAppointmentExtension) else {
            completion([], FayServerError.invalidUrl)
            return
        }

        var request = URLRequest(url: fetchUrl)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(loginToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = response as? HTTPURLResponse else {
                completion([], FayServerError.invalidServerResponse)
                return
            }

            if let data, let aptJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let appointmentsArray = aptJson["appointments"] as? [[String: Any]] {
                    var retApts: [Appointment] = []
                    for aptDict in appointmentsArray {
                        if let appointment = Appointment(dict: aptDict) {
                            retApts.append(appointment)
                        }
                    }
                    completion(retApts, nil)
                }
            }
        }
        task.resume()
    }

}

struct LoginDataResponse: Decodable {
    let token: String
}

struct LoginMessage: Encodable {
    let username: String
    let password: String
}

struct FetchAppointmentsResponse: Decodable {
    let appointments: [Appointment]
}

struct Appointment: Decodable, Hashable {
    var dietitianName = "Taylor Palmer"
    let appointment_id: String
    let patient_id: String
    let provider_id: String
    let status: String
    let appointment_type: String
    let start: Date
    let end: Date
    let duration_in_minutes: Int
    let recurrence_type: String

    static func ==(lhs: Appointment, rhs: Appointment) -> Bool {
        return lhs.appointment_id == rhs.appointment_id
    }

    public var isUpcoming: Bool {
        return start > Date()
    }

    public var timeRangeString: String {
        let startTime = Appointment.dateFormatter.string(from: start)
        let endTime = Appointment.dateFormatter.string(from: end)
        return startTime + " - " + endTime + " (PT)"
    }

    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "h:mm a"
        df.amSymbol = "AM"
        df.pmSymbol = "PM"
        return df
    }()

    init?(dict: [String: Any]) {
        guard let appointment_id = dict["appointment_id"] as? String,
              let patient_id = dict["patient_id"] as? String,
              let provider_id = dict["provider_id"] as? String,
              let status = dict["status"] as? String,
              let appointment_type = dict["appointment_type"] as? String,
              let startDateString = dict["start"] as? String,
              let endDateString = dict["end"] as? String,
              let duration_in_minutes = dict["duration_in_minutes"] as? Int,
              let recurrence_type = dict["recurrence_type"] as? String else {
            return nil
        }

        self.appointment_id = appointment_id
        self.patient_id = patient_id
        self.provider_id = provider_id
        self.status = status
        self.appointment_type = appointment_type

        guard let startDate = Server.dateFormatter.date(from: startDateString) else { return nil }
        guard let endDate = Server.dateFormatter.date(from: endDateString) else { return nil }
        self.start = startDate
        self.end = endDate

        self.duration_in_minutes = duration_in_minutes
        self.recurrence_type = recurrence_type
    }
}

enum FayServerError: Error {
    case invalidUrl
    case invalidMessageData
    case invalidServerResponse
    case invalidCredentials
    case notLoggedIn

    var description: String {
        switch self {
        case .invalidUrl, .invalidMessageData: return "Something went wrong. Please try again."
        case .invalidServerResponse: return "Something went wrong. Please try again later."
        case .invalidCredentials: return "Incorrect username or password."
        case .notLoggedIn: return "User needs to be logged in."
        }
    }
}
