//
//  TouchLineApp.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/4/26.
//

import SwiftUI
import SwiftData

@main
struct TouchLineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Player.self, Match.self, MatchPlayer.self])
    }
}
