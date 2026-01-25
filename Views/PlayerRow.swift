//
//  PlayerRow.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/8/26.
//

import SwiftUI
import SwiftData

struct PlayerRow: View {
    let match: Match
    @Bindable var matchPlayer: MatchPlayer
    let isMatchEnded: Bool
    @Binding var now: Date
    @State private var animateGoal = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(matchPlayer.snapshotName)
                    .bold()
                
                Text(formatTime(totalSeconds))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if matchPlayer.isOnField {
                    Text("On Field: \(formatTime(stintSeconds))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !matchPlayer.isOnField {
                    Text("On Bench: \(formatTime(benchSeconds))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let position = matchPlayer.currentPosition {
                    Text(position.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("No position")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(matchPlayer.isOnField ? "Sub Out" : "Sub In") { toggleSub() }
                .buttonStyle(.bordered)
                .disabled(isMatchEnded)
            
            // player goal
            if matchPlayer.isOnField && !isMatchEnded {
                Button {
                    match.addGoal(for: matchPlayer.player, at: now)
                } label: {
                    Image(systemName: "soccerball")
                        .scaleEffect(animateGoal ? 1.15 : 1.0)
                        .foregroundColor(animateGoal ? .green : .primary)
                        .animation(.easeOut(duration: 0.25), value: animateGoal)
                }
                .disabled(!match.hasStartedPlay || match.isEnded)
                .opacity(!match.hasStartedPlay ? 0.4 : 1.0)
                .buttonStyle(.bordered)
                .onChange(of: match.goals(for: matchPlayer.player)) {
                    animateGoal = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        animateGoal = false
                    }
                }
            }
            
            Menu("Position") {
                ForEach(Position.allCases, id: \.self) { pos in
                    Button(pos.rawValue.capitalized) {
                        match.changePosition(
                            for: matchPlayer,
                            to: pos,
                            at: now
                        )
                    }
                }
            }
            .disabled(!matchPlayer.isOnField || isMatchEnded)
        }
        .padding(.vertical, 4)
        .opacity(isMatchEnded ? 0.5 : 1.0)
    }
    
    private var totalSeconds: TimeInterval {
        max(0, matchPlayer.secondsPlayed(match: match, at: now))
    }

    private var stintSeconds: TimeInterval {
        max(0, matchPlayer.currentStintSeconds(match: match, at: now))
    }
    
    private var benchSeconds: TimeInterval {
        max(0, matchPlayer.benchSeconds(match: match, at: now))
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func toggleSub() {
        let current = now

        if matchPlayer.isOnField {
            match.subOut(player: matchPlayer, at: current)
        } else {
            match.subIn(player: matchPlayer, at: current)
        }
    }
}
