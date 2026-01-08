//
//  MatchView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/5/26.
//

import SwiftUI
import SwiftData

struct MatchView: View {
    @State private var showSetup = false
    @State private var activeMatch: Match?

    var body: some View {
        VStack {
            if let match = activeMatch {
                MatchActiveView(match: match)
            } else {
                Button("Start Match") {
                    showSetup = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Match")
        .sheet(isPresented: $showSetup) {
            NavigationStack {
                MatchSetupView { match in
                    activeMatch = match
                }
            }
        }
    }
}
