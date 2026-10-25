import SwiftUI

extension Color {
    // Team's Color(hex:) lives in PhotoDetails.swift; this one only adds opacity
    init(hex: UInt32, opacity: Double) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum Palette {
    static let brandPrimary = Color(hex: 0x164F3C)
    static let mint = Color(hex: 0xE5F4ED)
    static let mintStrong = Color(hex: 0xB3DEC2)
    static let progressTrack = Color(hex: 0xB0A7A7)
    static let progressLabel = Color(hex: 0x6D6D6D)
    static let secondaryLabel = Color(hex: 0x8E8E93)
    static let placeholderFill = Color(hex: 0xF2F2F7)
    static let placeholderStroke = Color(hex: 0xC7C7CC)
}
