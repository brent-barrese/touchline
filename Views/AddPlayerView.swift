//
//  AddPlayerView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/6/26.
//

import SwiftUI
import SwiftData

struct AddPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var jerseyNumber = ""

    var body: some View {
            NavigationStack {
                Form {
                    TextField("Name", text: $name)
                    TextField("Jersey Number", text: $jerseyNumber)
                        .keyboardType(.numberPad)
                }
                .navigationTitle("Add Player")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            savePlayer()
                        }
                        .disabled(name.isEmpty || Int(jerseyNumber) == nil)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    
    private func savePlayer() {
        guard let number = Int(jerseyNumber) else { return }

        let player = Player(name: name, jerseyNumber: number)
        modelContext.insert(player)
        dismiss()
    }
}

#Preview {
    AddPlayerView()
        .modelContainer(for: Player.self, inMemory: true)
}
