//
//  MatchView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/5/26.
//

import SwiftUI
import SwiftData
import Combine

struct MatchView: View {
    let match: Match
    var onMatchEnded: (() -> Void)? = nil

    @State private var now = Date()
    @State private var showEndConfirmation = false
    @State private var timerCancellable: Cancellable?

    var body: some View {
        VStack {
            ScoreboardHeader(
                match: match,
                now: now,
                onStartPlay: {
                    let kickoff = Date()
                    match.startPlay(at: kickoff)
                    now = kickoff
                },
                onPause: {
                    match.pause(at: now)
                },
                onResume: {
                    match.resume(at: now)
                },
                onHalftime: {
                    match.startHalftime(at: now)
                },
                onEndMatch: {
                    guard !match.isEnded else { return }
                    showEndConfirmation = true
                }
            )
            List {
                // sub suggestions
                if !match.isEnded && !match.isPaused {
                    SubSuggestionsView(match: match, now: now)
                }
                
                // on field
                Section("On the Field") {
                    ForEach(match.matchPlayers.filter { $0.isOnField }) { mp in
                        PlayerRow(
                            match: match,
                            matchPlayer: mp,
                            isMatchEnded: match.isEnded,
                            now: $now
                        )
                    }
                }
                
                // on bench
                Section("Bench") {
                    ForEach(match.matchPlayers.filter { !$0.isOnField }) { mp in
                        PlayerRow(
                            match: match,
                            matchPlayer: mp,
                            isMatchEnded: match.isEnded,
                            now: $now
                        )
                    }
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .alert("End Match?", isPresented: $showEndConfirmation) {
            Button("End Match", role: .destructive) { endMatch() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { newTime in
                now = newTime
                match.debugStatus(at: now)
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func endMatch() {
        guard !match.isEnded else { return }
        
        match.end(at: now)
        
        // 🔍 DEBUG — remove later
        print("=== MATCH EVENTS ===")
        for event in match.events {
            print(
                event.type.rawValue,
                "player:",
                event.player?.name ?? "-",
                "from:",
                event.fromPosition as Any,
                "to:",
                event.toPosition as Any,
                "@",
                event.timestamp
            )
        }
        print("====================")
        
        stopTimer()
        onMatchEnded?()
    }
}
