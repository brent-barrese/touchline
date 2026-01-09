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

    var body: some View {
        NavigationStack {
            if matches.isEmpty {
                ContentUnavailableView(
                    "No past matches",
                    systemImage: "clock"
                )
            } else {
                List {
                    ForEach(matches, id: \.persistentModelID) { match in
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
                                    .foregroundColor(
                                        match.isEnded ? .secondary : .green
                                    )
                            }
                        }
                    }
                    .onDelete(perform: deleteMatches)
                }
            }
        }
        .navigationTitle("Match History")
    }

    private func deleteMatches(at offsets: IndexSet) {
        for index in offsets {
            let match = matches[index]

            guard match.isEnded else { continue }

            modelContext.delete(match)
        }
    }
}
