//
//  MatchPlayer.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftData
import SwiftUI

@Model
class MatchPlayer{
    var player: Player
    var totalSecondsPlayed: TimeInterval = 0
    var isOnField: Bool = false
    var lastSubInTime: Date?
    
    init(player: Player){
        self.player = player
    }
    
    func secondsPlayed(at now: Date) -> TimeInterval {
            if isOnField, let lastIn = lastSubInTime {
                return totalSecondsPlayed + now.timeIntervalSince(lastIn)
            } else {
                return totalSecondsPlayed
            }
        }
}

extension MatchPlayer {
    func isUnderplayed(
        at now: Date,
        comparedTo average: TimeInterval,
        threshold: TimeInterval = 60
    ) -> Bool {
        secondsPlayed(at: now) + threshold < average
    }
}
