//
//  Player.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/6/26.
//

import SwiftData

@Model
class Player {
    var name: String
    var jerseyNumber: Int

    init(name: String, jerseyNumber: Int) {
        self.name = name
        self.jerseyNumber = jerseyNumber
    }
}
