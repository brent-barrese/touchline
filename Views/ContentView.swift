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
    @Query private var items: [Item]

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Players"){
                    PlayersView()
                }
                NavigationLink("Start Match"){
                    MatchView()
                }
                NavigationLink("Previous Matches"){
                    MatchHistoryView()
                }
            }
            .navigationTitle("Test")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
