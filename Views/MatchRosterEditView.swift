//
//  MatchRosterEditView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/25/26.
//

import SwiftUI
import SwiftData

struct MatchRosterEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Player.jerseyNumber)
    private var allPlayers: [Player]

    let match: Match
    let now = Date()

    var body: some View {
        NavigationStack {
            List {
                ForEach(allPlayers) { player in
                    HStack {
                        Text("#\(player.jerseyNumber)")
                            .frame(width: 40)

                        Text(player.name)

                        Spacer()

                        if let mp = match.matchPlayers.first(where: { $0.player == player }) {
                            // Already in match → allow remove
                            Button("Remove") {
                                match.removePlayerFromMatch(mp)
                            }
                            .foregroundStyle(.red)
                            .disabled(mp.isOnField) // must sub out first
                        } else {
                            // Not in match → allow add
                            Button("Add") {
                                match.addPlayerToMatch(player, at: now)
                            }
                            .foregroundStyle(.green)
                        }
                    }
                }
            }
            .navigationTitle("Match Roster")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
