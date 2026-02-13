//
//  ContentView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Match> { $0.endTime == nil })
    private var activeMatches: [Match]

    @State private var activeMatch: Match?
    @State private var showSetup = false
    @State private var showMatch = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Active match banner
                if let match = activeMatches.first {
                    CardButton(
                        title: "Resume Match",
                        systemImage: "play.circle.fill",
                        color: .green
                    ) {
                        activeMatch = match
                        showMatch = true
                    }
                }

                // Start match card
                CardButton(
                    title: "Start Match",
                    systemImage: "plus.circle.fill",
                    color: .blue,
                    disabled: activeMatches.first != nil
                ) {
                    showSetup = true
                }

                // Players card
                NavigationLink(destination: PlayersView()) {
                    CardView(title: "Players", systemImage: "person.3.fill", backgroundColor: .orange)
                }

                // Previous Matches card
                NavigationLink(destination: MatchHistoryView()) {
                    CardView(title: "Previous Matches", systemImage: "clock.fill", backgroundColor: .teal)
                }

                Spacer()
                
//                // --- LOGO ADDED HERE ---
//                Image("psa-logo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 100) // Adjust height as needed
//                    .padding(.vertical, 20)
//                // -----------------------
            }
            .padding()
            .navigationTitle("TouchLine")
            
            // Navigate to MatchView if Resume pressed
            .navigationDestination(isPresented: $showMatch) {
                if let match = activeMatch {
                    MatchView(match: match)
                } else {
                    Text("No active match")
                }
            }

            // Show MatchSetupView sheet
            .sheet(isPresented: $showSetup) {
                NavigationStack {
                    MatchSetupView { newMatch in
                        activeMatch = newMatch
                        showSetup = false
                        showMatch = true
                    }
                }
            }
        }
    }
}

// MARK: - CardButton
struct CardButton: View {
    let title: String
    let systemImage: String
    let color: Color
    var disabled: Bool = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            if !disabled { action() }
        }) {
            CardView(title: title, systemImage: systemImage, backgroundColor: color)
                .opacity(disabled ? 0.4 : 1.0)
                .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .disabled(disabled)
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                pressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - CardView
struct CardView: View {
    let title: String
    let systemImage: String
    let backgroundColor: Color

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 30)
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor.opacity(0.2))
        .foregroundColor(backgroundColor)
        .cornerRadius(12)
        .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
