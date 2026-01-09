//
//  ContentView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    // Detect any active match in the database
    @Query(filter: #Predicate<Match> { $0.endTime == nil })
    private var activeMatches: [Match]

    // Track the match the user is currently viewing/starting
    @State private var activeMatch: Match?
    @State private var showSetup = false
    @State private var showMatch = false // <-- needed for navigationDestination

    var body: some View {
        NavigationStack {
            List {
                // Resume active match
                if let match = activeMatches.first {
                    Label("Resume Current Match", systemImage: "soccerball")
                        .foregroundStyle(.green)
                        .onTapGesture {
                            activeMatch = match
                            showMatch = true
                        }
                }

                NavigationLink("Players") {
                    PlayersView()
                }

                // Start Match button
                Button("Start Match") {
                    showSetup = true
                }
                .disabled(activeMatches.first != nil) // only disable if a truly active match exists

                NavigationLink("Previous Matches") {
                    MatchHistoryView()
                }
            }
            .navigationTitle("TouchLine")

            // Programmatic navigation to MatchView
            .navigationDestination(isPresented: $showMatch) {
                if let match = activeMatch {
                    MatchView(match: match)
                } else {
                    Text("No active match")
                }
            }

            // Start Match sheet
            .sheet(isPresented: $showSetup) {
                NavigationStack {
                    MatchSetupView { newMatch in
                        // After creating match, navigate to it
                        activeMatch = newMatch
                        showSetup = false
                        showMatch = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
