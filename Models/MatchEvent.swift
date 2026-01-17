//
//  MatchEvent.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/17/26.
//

import SwiftData
import SwiftUI

@Model
class MatchEvent {
    var type: MatchEventType
    var timestamp: TimeInterval
    var player: Player?
    var fromPosition: Position?
    var toPosition: Position?

    init(
        type: MatchEventType,
        timestamp: TimeInterval,
        player: Player? = nil,
        fromPosition: Position? = nil,
        toPosition: Position? = nil
    ) {
        self.type = type
        self.timestamp = timestamp
        self.player = player
        self.fromPosition = fromPosition
        self.toPosition = toPosition
    }
}
