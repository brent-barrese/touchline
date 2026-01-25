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
    @State private var editingPlayer: Player?
    @State private var showDeleteConfirmation = false
    @State private var playerToDelete: Player?

    var body: some View {
        List {
            ForEach(players) { player in
                HStack {
                    Text("#\(player.jerseyNumber)")
                        .bold()
                        .frame(width: 40, alignment: .leading)

                    Text(player.name)
                    Spacer()
                }
                .swipeActions(edge: .trailing) {
                    Button("Edit") {
                        editingPlayer = player
                    }
                    .tint(.blue)

                    Button("Delete") {
                        playerToDelete = player
                        showDeleteConfirmation = true
                    }
                    .tint(.red)
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
            AddPlayerView()
        }
        .sheet(item: $editingPlayer) { player in
            PlayerEditView(player: player)
        }
        .alert("Delete Player?", isPresented: $showDeleteConfirmation, presenting: playerToDelete) { player in
            Button("Delete", role: .destructive) {
                delete(player)
            }
            Button("Cancel", role: .cancel) {
                playerToDelete = nil
            }
        } message: { _ in
            Text("Deleting this player will not affect past matches.")
        }
    }

    private func delete(_ player: Player) {
        modelContext.delete(player)
    }
}
