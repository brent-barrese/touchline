//
//  PlayersView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/5/26.
//

import SwiftUI
import SwiftData

struct PlayersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Player.jerseyNumber) private var players: [Player]

    @State private var showAddPlayer = false

    var body: some View {
        List {
            ForEach(players) { player in
                HStack {
                    Text("#\(player.jerseyNumber)")
                        .bold()
                        .frame(width: 40, alignment: .leading)

                    Text(player.name)
                }
            }
        }
        .navigationTitle("Players")
        .toolbar {
            Button {
                showAddPlayer = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddPlayer) {
            AddPlayerView() // no modelContainer here
        }
    }
}

#Preview {
    AddPlayerView()
        .modelContainer(for: Player.self, inMemory: true)
}
