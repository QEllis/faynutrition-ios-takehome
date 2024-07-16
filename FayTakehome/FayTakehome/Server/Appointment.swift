//
//  Appointment.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import Foundation

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
