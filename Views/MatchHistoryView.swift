//
//  MatchHistoryView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI
import SwiftData

struct MatchHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Match.startTime, order: .reverse)
    private var matches: [Match]

    // Local snapshot for ended matches to avoid SwiftData live-query crash
    @State private var endedMatches: [Match] = []

    var body: some View {
        NavigationStack {
            if matches.isEmpty {
                ContentUnavailableView(
                    "No past matches",
                    systemImage: "clock"
                )
            } else {
                List {
                    // In Progress Matches (read-only)
                    let activeMatches = matches.filter { !$0.isEnded }
                    if !activeMatches.isEmpty {
                        Section("In Progress") {
                            ForEach(activeMatches, id: \.persistentModelID) { match in
                                matchRow(match)
                            }
                        }
                    }

                    // Ended Matches (deletable)
                    if !endedMatches.isEmpty {
                        Section("Ended Matches") {
                            ForEach(endedMatches, id: \.persistentModelID) { match in
                                matchRow(match)
                            }
                            .onDelete(perform: deleteEndedMatches)
                        }
                    }
                }
            }
        }
        .navigationTitle("Match History")
        .onAppear {
            // Initialize snapshot from live query
            endedMatches = matches.filter { $0.isEnded }
        }
    }

    // Delete from Core Data and remove from snapshot
    private func deleteEndedMatches(at offsets: IndexSet) {
        let toDelete = offsets.map { endedMatches[$0] }

        for match in toDelete {
            modelContext.delete(match)
        }

        withAnimation {
            endedMatches.remove(atOffsets: offsets)
        }
    }

    @ViewBuilder
    private func matchRow(_ match: Match) -> some View {
        NavigationLink {
            MatchSummaryView(match: match)
        } label: {
            HStack {
                Text(match.startTime.formatted(date: .abbreviated, time: .shortened))
                Spacer()
                Text(match.isEnded ? "Ended" : "In Progress")
                    .foregroundColor(match.isEnded ? .secondary : .green)
            }
        }
    }
}
