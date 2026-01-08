//
//  TimeFormatter.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import Foundation

func formatTime(_ seconds: TimeInterval) -> String {
    let total = Int(seconds)
    let minutes = total / 60
    let secs = total % 60
    return String(format: "%02d:%02d", minutes, secs)
}
