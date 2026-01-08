//
//  MatchClockView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI

struct MatchClockView: View {
    let elapsedSeconds: TimeInterval

    var body: some View {
        Text(formattedTime)
            .font(.system(size: 36, weight: .bold, design: .monospaced))
            .padding(.vertical)
    }

    private var formattedTime: String {
        let total = Int(elapsedSeconds)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
