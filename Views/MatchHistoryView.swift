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
    
    private var activeMatches: [Match] {
        matches.filter { !$0.isEnded }
    }

    private var endedMatches: [Match] {
        matches.filter { $0.isEnded }
    }

    var body: some View {
        NavigationStack {
            if matches.isEmpty {
                ContentUnavailableView(
                    "No past matches",
                    systemImage: "clock"
                )
            } else {
                List {
                    if !activeMatches.isEmpty {
                        Section("In Progress") {
                            ForEach(activeMatches, id: \.persistentModelID) { match in
                                matchRow(match)
                            }
                        }
                    }

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
    }

    private func deleteEndedMatches(at offsets: IndexSet) {
        for index in offsets {
            let match = endedMatches[index]
            modelContext.delete(match)
        }
    }
    
    @ViewBuilder
    private func matchRow(_ match: Match) -> some View {
        NavigationLink {
            MatchSummaryView(match: match)
        } label: {
            HStack {
                Text(
                    match.startTime.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )

                Spacer()

                Text(match.isEnded ? "Ended" : "In Progress")
                    .foregroundColor(match.isEnded ? .secondary : .green)
            }
        }
    }
}
