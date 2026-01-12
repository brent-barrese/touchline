//
//  SportType.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/11/26.
//

enum SportType: String, Codable, CaseIterable {
    case soccer
    case basketball
}

// for future use
extension SportType {
    var surfaceName: String {
        switch self {
        case .soccer: return "Field"
        case .basketball: return "Court"
        }
    }
}
