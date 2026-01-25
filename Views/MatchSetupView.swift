//
//  MatchSetupView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI
import SwiftData
import Foundation

struct MatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Match> { $0.endTime == nil })
    private var activeMatches: [Match]

    @Query(sort: \Player.jerseyNumber)
    private var players: [Player]

    @State private var selectedPlayerIDs: Set<UUID> = []
    @State private var matchName: String = ""
    @State private var editingPlayer: Player?

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
                
                // ---------- Select All toggle ----------
                Toggle("Select All Players", isOn: Binding(
                    get: { selectedPlayerIDs.count == players.count && !players.isEmpty },
                    set: { newValue in
                        selectedPlayerIDs = newValue ? Set(players.map { $0.id }) : []
                    }
                ))
                .padding(.horizontal)
                
                // Player selection with edit/delete
                List {
                    ForEach(players) { player in
                        HStack {
                            Text("#\(player.jerseyNumber)")
                                .frame(width: 40, alignment: .leading)
                            Text(player.name)
                            Spacer()

                            if selectedPlayerIDs.contains(player.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }

                            Button {
                                editingPlayer = player
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.plain)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(player)
                        }
                    }
                    .onDelete(perform: deletePlayer)
                }
                .sheet(item: $editingPlayer) { player in
                    PlayerEditView(player: player)
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

    private func toggleSelection(_ player: Player) {
        if selectedPlayerIDs.contains(player.id) {
            selectedPlayerIDs.remove(player.id)
        } else {
            selectedPlayerIDs.insert(player.id)
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        for index in offsets {
            let player = players[index]
            modelContext.delete(player)
            selectedPlayerIDs.remove(player.id)
        }
    }

    private func startMatch() {
        let selectedPlayers = players.filter {
            selectedPlayerIDs.contains($0.id)
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
