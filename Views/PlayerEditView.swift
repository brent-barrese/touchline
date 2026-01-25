//
//  PlayerEditView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/24/26.
//

import SwiftUI
import SwiftData

struct PlayerEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player

    var body: some View {
        NavigationStack {
            Form {
                Section("Player Info") {
                    TextField("Name", text: $player.name)
                    TextField("Jersey Number", value: $player.jerseyNumber, format: .number)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Player")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
