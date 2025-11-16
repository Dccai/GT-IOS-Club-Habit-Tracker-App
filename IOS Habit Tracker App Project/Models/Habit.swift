import Foundation
import SwiftUI

enum HabitRepeat: Equatable {
    case daily
    case weekdays
    case weekends
    case weekly
    case customWeekdays(Set<Weekday>)
}

enum Weekday: Int, CaseIterable, Hashable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

struct Habit: Identifiable {
    var id: UUID = UUID()
    
    var name: String
    var label: String
    var progress: Int
    var colorIndex: Int
    var goal: Int
    var unit: String
    
    var startDate: Date
    var repeatRule: HabitRepeat
    var isWeekly: Bool
}

extension Habit {
    func occurs(on date: Date, calendar: Calendar) -> Bool {
        if date < calendar.startOfDay(for: startDate) {
            return false
        }
        
        let weekday = calendar.component(.weekday, from: date)
        let startWeekday = calendar.component(.weekday, from: startDate)
        
        switch repeatRule {
        case .daily:
            return true
            
        case .weekdays:
            return weekday != 1 && weekday != 7
        case .weekends:
            return weekday == 1 || weekday == 7
            
        case .weekly:
            guard weekday == startWeekday else { return false }
            let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate),
                                                   to: calendar.startOfDay(for: date)).day ?? 0
            return daysDiff % 7 == 0
            
        case .customWeekdays(let allowed):
            guard let wd = Weekday(rawValue: weekday) else { return false }
            return allowed.contains(wd)
        }
    }
}

let colors: [Color] = [
    Color(red: 1.0, green: 0.6, blue: 0.6),
    Color(red: 1.0, green: 0.8, blue: 0.5),
    Color(red: 1.0, green: 0.95, blue: 0.5),
    Color(red: 0.6, green: 0.9, blue: 0.6),
    Color(red: 0.6, green: 0.85, blue: 0.95),
    Color(red: 0.6, green: 0.7, blue: 0.95),
    Color(red: 0.7, green: 0.6, blue: 0.95),
    Color(red: 1.0, green: 0.7, blue: 0.8),
    Color(red: 0.85, green: 0.6, blue: 0.95),
    Color(red: 0.75, green: 0.7, blue: 0.65),
    Color(red: 0.7, green: 0.7, blue: 0.7),
    Color(red: 0.9, green: 0.85, blue: 0.85)
]

let sampleHabits: [Habit] = {
    let calendar = Calendar.current
    let today = Date()
    
    return [
        Habit(
            name: "Drink Water",
            label: "💧",
            progress: 32,
            colorIndex: 4,
            goal: 80,
            unit: "oz",
            startDate: today,
            repeatRule: .daily,
            isWeekly: false
        ),
        Habit(
            name: "Workout",
            label: "🏋️‍♂️",
            progress: 1,
            colorIndex: 1,
            goal: 1,
            unit: "session",
            startDate: today,
            repeatRule: .daily,
            isWeekly: false
        ),
        Habit(
            name: "Call Family",
            label: "📞",
            progress: 0,
            colorIndex: 0,
            goal: 1,
            unit: "time",
            startDate: today,
            repeatRule: .weekdays,
            isWeekly: false
        ),
        Habit(
            name: "Weekly Review",
            label: "📝",
            progress: 0,
            colorIndex: 3,
            goal: 1,
            unit: "time",
            startDate: today,
            repeatRule: .daily,
            isWeekly: true
        )
    ]
}()
