//
//  QuestProvider.swift
//  MyApp
//
//  Created by Rifal  on 11/05/1448 AH.
//

import Foundation

/// Picks the daily quests. Works fully offline: the quest list ships inside the
/// app (Quests.json) and today's quests are derived from the date alone, so the
/// same day always gives the same quests, on every launch and every phone.
enum QuestProvider {
    struct Quest: Decodable {
        let id: Int
        let title: String
    }

    static let questsPerDay = 3

    // Used only if Quests.json is missing or unreadable
    private static let fallback = [
        "Find something orange",
        "Find something red",
        "Find something round"
    ]

    // Counting starts from this day. Never change it, or everyone's quests shift.
    private static let startDate = DateComponents(year: 2026, month: 1, day: 1)

    static let allTitles: [String] = {
        guard let url = Bundle.main.url(forResource: "Quests", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quests = try? JSONDecoder().decode([Quest].self, from: data)
        else { return fallback }

        let titles = quests.map(\.title)
        return titles.count >= questsPerDay ? titles : fallback
    }()

    /// The three quests for the given day, in the order they are completed.
    static func quests(for date: Date = Date(), calendar: Calendar = .current) -> [String] {
        let titles = allTitles
        // Only whole groups of three are used, so no quest repeats inside a cycle
        let daysPerCycle = max(titles.count / questsPerDay, 1)

        let dayIndex = dayNumber(of: date, calendar: calendar)
        let cycle = dayIndex / daysPerCycle
        let dayInCycle = dayIndex % daysPerCycle

        // Same shuffle for the whole cycle, a different one for the next cycle
        var generator = SeededGenerator(seed: UInt64(cycle))
        let order = Array(titles.indices).shuffled(using: &generator)

        let start = dayInCycle * questsPerDay
        return order[start..<start + questsPerDay].map { titles[$0] }
    }

    /// Days since `startDate`, using the user's own calendar day (their midnight, not UTC)
    private static func dayNumber(of date: Date, calendar: Calendar) -> Int {
        guard let start = calendar.date(from: startDate) else { return 0 }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: start),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        return max(days, 0)
    }
}

/// A random generator that always gives the same numbers for the same seed
/// (SplitMix64). The system generator can't be seeded, so it can't be used here.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
