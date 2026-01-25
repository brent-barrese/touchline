//
//  ScoreboardHeader.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/21/26.
//

import SwiftUI
import SwiftData

struct ScoreboardHeader: View {
    let match: Match
    let now: Date
    let onStartPlay: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onHalftime: () -> Void
    let onEndMatch: () -> Void
    @State private var animateFor = false
    @State private var animateAgainst = false

    var body: some View {
        let displaySeconds = match.isEnded
            ? (match.finalElapsedSeconds ?? match.elapsedSeconds(at: now))
            : match.elapsedSeconds(at: now)
        
        VStack(spacing: 8) {
            // Match name
            Text(match.name)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Clock (smaller, centered above the scores)
            Text(formatTime(displaySeconds))
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .monospacedDigit()
                .opacity(match.isEnded ? 0.4 : 1.0)

            // Score row
            HStack(alignment: .bottom, spacing: 20) {

                // US
                VStack(spacing: 2) {
                    Text("US")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(match.goalsFor)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(animateFor ? .green : .primary)
                        .scaleEffect(animateFor ? 1.15 : 1.0)
                        .animation(.easeOut(duration: 0.25), value: animateFor)
                }

                Text("–")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)

                // OPP + / -
                VStack(spacing: 2) {
                    Text("OPP")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 6) {
                        Button {
                            match.removeLastOpponentGoal()
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .disabled(!match.hasStartedPlay || match.goalsAgainst == 0)
                        .opacity(!match.hasStartedPlay ? 0.4 : 1.0)

                        Text("\(match.goalsAgainst)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(animateAgainst ? .red : .primary)
                            .scaleEffect(animateAgainst ? 1.15 : 1.0)
                            .animation(.easeOut(duration: 0.25), value: animateAgainst)

                        Button {
                            match.addOpponentGoal(at: now)
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(!match.hasStartedPlay)
                        .opacity(!match.hasStartedPlay ? 0.4 : 1.0)
                    }
                }
            }

            // Match controls
            HStack(spacing: 12) {
                if !match.hasStartedPlay && !match.isEnded {
                    Button(action: onStartPlay) {
                        Label("Start", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }

                if match.isPaused && !match.isEnded {
                    Button(action: onResume) {
                        Label("Resume", systemImage: "play.fill")
                    }
                    .buttonStyle(.bordered)
                }

                if match.hasStartedPlay && !match.isPaused && !match.isEnded {
                    Button(action: onPause) {
                        Label("Pause", systemImage: "pause.fill")
                    }

                    Button(action: onHalftime) {
                        Label("Halftime", systemImage: "pause.circle")
                    }
                    .disabled(match.hasHadHalftime)
                    .opacity(match.hasHadHalftime ? 0.4 : 1.0)
                }

                Spacer()

                Button(action: onEndMatch) {
                    Text("End Match")
                }
                .buttonStyle(.bordered)
                .disabled(match.isEnded)
                .opacity(match.isEnded ? 0.4 : 1.0)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .onChange(of: match.goalsFor) {
            animateFor = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                animateFor = false
            }
        }

        .onChange(of: match.goalsAgainst) {
            animateAgainst = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                animateAgainst = false
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds / 60)
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
