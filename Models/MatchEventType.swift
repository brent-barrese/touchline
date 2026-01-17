//
//  MatchEvent.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/17/26.
//

enum MatchEventType: String, Codable {
    case goal
    case opponentGoal
    case positionChange
    case keeperChange
}
