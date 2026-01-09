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

    @Query(sort: \Player.jerseyNumber) private var players: [Player]

    @State private var selectedPlayerIDs: Set<PersistentIdentifier> = []
    
    let onMatchCreated: (Match) -> Void

    var body: some View {
        VStack(spacing: 20) {

            // ----- Active match prompt -----
            if let currentMatch = activeMatches.first {
                VStack(spacing: 16) {
                    Text("A match is already in progress")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    Button("Resume Match") {
                        dismiss() // go back to MatchView
                    }
                    .buttonStyle(.borderedProminent)

                    Button("End Match") {
                        currentMatch.endTime = Date()
                        dismiss() // go back to start match screen
                    }
                    .foregroundStyle(.red)
                }
                .padding()
            }

            // ----- Player selection -----
            if activeMatches.isEmpty {
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
        onMatchCreated(match)  // notify parent to navigate
        dismiss()
    }
}

// it was working here - 1.
//struct MatchSetupView: View {
//    @Query(filter: #Predicate<Match> { $0.endTime == nil })
//    private var activeMatches: [Match]
//    
//    let onMatchCreated: (Match) -> Void
//    
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//
//    @Query(sort: \Player.jerseyNumber) private var players: [Player]
//
//    @State private var selectedPlayerIDs: Set<PersistentIdentifier> = []
//
//    var body: some View {
//        
//        if let match = activeMatches.first {
//            VStack(spacing: 16) {
//                Text("A match is already in progress")
//                    .font(.headline)
//
//                Button("Resume Match") {
//                    dismiss()
//                }
//                .buttonStyle(.borderedProminent)
//
//                Button("End Match") {
//                    match.endTime = Date()
//                    dismiss()
//                }
//                .foregroundStyle(.red)
//            }
//            .padding()
//        } else {
//            List(players) { player in
//                Button {
//                    toggle(player)
//                } label: {
//                    HStack {
//                        Text("#\(player.jerseyNumber)")
//                            .frame(width: 40)
//
//                        Text(player.name)
//
//                        Spacer()
//
//                        if selectedPlayerIDs.contains(player.persistentModelID) {
//                            Image(systemName: "checkmark.circle.fill")
//                                .foregroundStyle(.green)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Select Players")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Start Match") {
//                        startMatch()
//                    }
//                    .disabled(selectedPlayerIDs.isEmpty)
//                }
//            }
//        }
//    }
//
//    private func toggle(_ player: Player) {
//        let id = player.persistentModelID
//        if selectedPlayerIDs.contains(id) {
//            selectedPlayerIDs.remove(id)
//        } else {
//            selectedPlayerIDs.insert(id)
//        }
//    }
//
//    private func startMatch() {
//        let selectedPlayers = players.filter {
//            selectedPlayerIDs.contains($0.persistentModelID)
//        }
//
//        let match = Match(players: selectedPlayers)
//        modelContext.insert(match)
//        onMatchCreated(match)
//        dismiss()
//    }
//}
