//
//  goalextensions.swift
//  HabitMaster
//
//  Created by Roohi Tatavarty on 4/11/22.
//

import Foundation
import CoreData

extension GoalModel {




    public var dayArray: [DaysModel] {
        let set = trackeddays as? Set<DaysModel> ?? []
        return set.sorted {
            $0.dt ?? Date()  < $1.dt ?? Date()
        }
    }

    public var currentStreak: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let sortedDays = dayArray.filter { $0.dt ?? Date() <= today }

        var streak = 0
        var checkDate = today

        // Count backwards from today
        for day in sortedDays.reversed() {
            guard let dayDate = day.dt else { continue }
            let dayStart = cal.startOfDay(for: dayDate)

            if dayStart == checkDate {
                if day.status {
                    streak += 1
                    guard let previousDay = cal.date(byAdding: .day, value: -1, to: checkDate) else { break }
                    checkDate = previousDay
                } else {
                    break
                }
            }
        }

        return streak
    }

    public var longestStreak: Int {
        let cal = Calendar.current
        let sortedDays = dayArray.filter { ($0.dt ?? Date()) <= Date() }

        var maxStreak = 0
        var currentCount = 0
        var lastDate: Date?

        for day in sortedDays {
            guard let dayDate = day.dt else { continue }

            if day.status {
                if let last = lastDate,
                   let daysBetween = cal.dateComponents([.day], from: cal.startOfDay(for: last), to: cal.startOfDay(for: dayDate)).day,
                   daysBetween == 1 {
                    currentCount += 1
                } else {
                    currentCount = 1
                }
                maxStreak = max(maxStreak, currentCount)
                lastDate = dayDate
            } else {
                currentCount = 0
                lastDate = nil
            }
        }

        return maxStreak
    }

    public var totalnow: String {
        let set = trackeddays as? Set<DaysModel> ?? []
        let now = Date()
        let today = Calendar.current.startOfDay(for: now)

        let committed = set.filter { day in
            guard let date = day.dt else { return false }
            return day.status && date < now
        }.count

        let remaining = set.filter { day in
            guard let date = day.dt else { return false }
            return date > today
        }.count

        return "\(committed) days Committed, \(remaining) to go."
    }
}
