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
