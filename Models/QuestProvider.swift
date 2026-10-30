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
///
/// Each day has one quest per category, in the order the categories first appear
/// in Quests.json: quest 1 = category 1, quest 2 = category 2, quest 3 = category 3.
enum QuestProvider {
    struct Quest: Decodable {
        let id: Int
        let title: String
        let category: String?
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

    private static let allQuests: [Quest] = {
        guard let url = Bundle.main.url(forResource: "Quests", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quests = try? JSONDecoder().decode([Quest].self, from: data)
        else { return [] }
        return quests
    }()

    static let allTitles: [String] = {
        let titles = allQuests.map(\.title)
        return titles.count >= questsPerDay ? titles : fallback
    }()

    /// Titles grouped by category, categories in order of first appearance in the file.
    /// Only the first `questsPerDay` categories are used (one quest each).
    private static let categories: [[String]] = {
        var order: [String] = []
        var groups: [String: [String]] = [:]
        for quest in allQuests {
            guard let category = quest.category, !category.isEmpty else { continue }
            if groups[category] == nil { order.append(category) }
            groups[category, default: []].append(quest.title)
        }
        return order.prefix(questsPerDay).compactMap { groups[$0] }
    }()

    /// The three quests for the given day, in the order they are completed.
    static func quests(for date: Date = Date(), calendar: Calendar = .current) -> [String] {
        let day = dayNumber(of: date, calendar: calendar)

        // One quest from each category
        if categories.count == questsPerDay, categories.allSatisfy({ !$0.isEmpty }) {
            return categories.enumerated().map { index, titles in
                pick(from: titles, day: day, salt: UInt64(index))
            }
        }

        // No categories in the file: three quests from the whole list, never repeating inside a cycle
        return pickGroup(from: allTitles, day: day)
    }

    /// One quest of a category for the day. Each quest shows up once per cycle
    /// (cycle length = number of quests in the category), in a shuffled order that
    /// changes every cycle.
    private static func pick(from titles: [String], day: Int, salt: UInt64) -> String {
        let cycle = day / titles.count
        let position = day % titles.count

        var generator = SeededGenerator(seed: UInt64(cycle) &* 31 &+ salt &+ 1)
        let order = Array(titles.indices).shuffled(using: &generator)
        return titles[order[position]]
    }

    /// Three quests from one list (used only when the file has no categories).
    private static func pickGroup(from titles: [String], day: Int) -> [String] {
        // Only whole groups of three are used, so no quest repeats inside a cycle
        let daysPerCycle = max(titles.count / questsPerDay, 1)
        let cycle = day / daysPerCycle
        let dayInCycle = day % daysPerCycle

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
