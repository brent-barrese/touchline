//
//  MatchHistoryView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI
import SwiftData

struct MatchHistoryView: View {
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
                List(matches, id: \.persistentModelID) { match in
                    NavigationLink(
                        destination: MatchSummaryView(match: match),
                        label: {
                            HStack {
                                Text(
                                    match.startTime.formatted(
                                        date: .abbreviated,
                                        time: .shortened
                                    )
                                )

                                Spacer()

                                Text(match.endTime != nil ? "Ended" : "In Progress")
                                    .foregroundColor(match.endTime != nil ? .secondary : .green)
                            }
                        }
                    )
                }
            }
        }
        .navigationTitle("Match History")
    }
}
