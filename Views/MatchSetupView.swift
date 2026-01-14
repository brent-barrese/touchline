//
//  MatchSetupView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI
import SwiftData

struct MatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Match> { $0.endTime == nil })
    private var activeMatches: [Match]

    @Query(sort: \Player.jerseyNumber)
    private var players: [Player]

    @State private var selectedPlayerIDs: Set<PersistentIdentifier> = []
    @State private var matchName: String = ""

    let onMatchCreated: (Match) -> Void

    var body: some View {
        VStack(spacing: 16) {

            // ---------- Active match guard ----------
            if let currentMatch = activeMatches.first {
                VStack(spacing: 12) {
                    Text("A match is already in progress")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    Button("Resume Match") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("End Match") {
                        currentMatch.endTime = Date()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                .padding()
            }

            // ---------- New match setup ----------
            if activeMatches.isEmpty {

                // Match name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Match Info")
                        .font(.headline)

                    TextField("Match name (optional)", text: $matchName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                // Player selection
                List(players) { player in
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
                    .contentShape(Rectangle())     // ⭐ makes entire row tappable
                    .onTapGesture {
                        toggle(player)
                    }
                }
            }
        }
        .navigationTitle("New Match")
        .toolbar {
            if activeMatches.isEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start Match") {
                        startMatch()
                    }
                    .disabled(selectedPlayerIDs.isEmpty)
                }
            }
        }
    }

    // MARK: - Helpers

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

        let finalName =
            matchName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Match \(Date().formatted(date: .abbreviated, time: .shortened))"
            : matchName

        let match = Match(
            name: finalName,
            players: selectedPlayers
        )

        modelContext.insert(match)
        onMatchCreated(match)
        dismiss()
    }
}
