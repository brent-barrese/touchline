//
//  Player.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/6/26.
//

import SwiftData
import Foundation

@Model
class Player: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var jerseyNumber: Int

    init(name: String, jerseyNumber: Int) {
        self.name = name
        self.jerseyNumber = jerseyNumber
    }
}
