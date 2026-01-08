//
//  MatchSetupView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI
import SwiftData

struct MatchSetupView: View {
    let onMatchCreated: (Match) -> Void
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Player.jerseyNumber) private var players: [Player]

    @State private var selectedPlayerIDs: Set<PersistentIdentifier> = []

    var body: some View {
        List(players) { player in
            Button {
                toggle(player)
            } label: {
                HStack {
                    Text("#\(player.jerseyNumber)")
                        .frame(width: 40)

                    Text(player.name)

                    Spacer()

                    if selectedPlayerIDs.contains(player.persistentModelID) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .navigationTitle("Select Players")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Start Match") {
                    startMatch()
                }
                .disabled(selectedPlayerIDs.isEmpty)
            }
        }
    }

    private func toggle(_ player: Player) {
        let id = player.persistentModelID
        if selectedPlayerIDs.contains(id) {
            selectedPlayerIDs.remove(id)
        } else {
            selectedPlayerIDs.insert(id)
        }
    }

    private func startMatch() {
        let selectedPlayers = players.filter {
            selectedPlayerIDs.contains($0.persistentModelID)
        }

        let match = Match(players: selectedPlayers)
        modelContext.insert(match)
        onMatchCreated(match)
        dismiss()
    }
}
