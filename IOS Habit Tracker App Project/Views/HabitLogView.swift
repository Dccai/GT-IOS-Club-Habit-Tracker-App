import SwiftUI

let sampleHabits: [Habit] = {
    let calendar = Calendar.current
    let today = Date()
    
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) ?? today
    let lastWeek = calendar.date(byAdding: .day, value: -7, to: today) ?? today
    
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
            name: "Drink Water",
            label: "💧",
            progress: 32,
            colorIndex: 1,
            goal: 80,
            unit: "oz",
            startDate: today,
            repeatRule: .daily,
            isWeekly: false
        ),
        Habit(
            name: "Drink Water",
            label: "💧",
            progress: 32,
            colorIndex: 1,
            goal: 80,
            unit: "oz",
            startDate: today,
            repeatRule: .daily,
            isWeekly: false
        ),
        Habit(
            name: "Drink Water",
            label: "💧",
            progress: 32,
            colorIndex: 1,
            goal: 80,
            unit: "oz",
            startDate: today,
            repeatRule: .daily,
            isWeekly: false
        )
    ]
}()

struct HabitLogView: View {
    @Environment(\.calendar) private var calendar
    @State private var selectedDate = Date()
    private let habits = sampleHabits
    
    var body: some View {
            VStack(alignment: .leading, spacing: 12){
                HStack{
                    Spacer()
                    NavigationLink {
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain).padding(.bottom, 14)
                }

                Text("Habits").font(.system(size: 34, weight: .bold))
                DateSelector(selectedDate: $selectedDate).padding(.horizontal, -16)
                List {
                    Section(
                        header: Text("DAILY (\(dailyHabitsForSelectedDate.count))").foregroundStyle(.black)
                            .font(.system(size: 12, weight: .medium)).padding(.bottom, -16)){
                        if dailyHabitsForSelectedDate.isEmpty {
                            HStack {
                                Spacer()
                                Text("No habits")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                        } else {
                            ForEach(dailyHabitsForSelectedDate) { habit in
                                HabitCardView(displayInfo: habit)
                            }
                        }
                    }
                    
                    Section(
                        header: Text("WEEKLY (\(weeklyHabitsForSelectedDate.count))").foregroundStyle(.black)
                            .font(.system(size: 12, weight: .medium)).padding(.vertical, -16)){
                        if weeklyHabitsForSelectedDate.isEmpty {
                            HStack {
                                Spacer()
                                Text("No habits")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                        } else {
                            ForEach(weeklyHabitsForSelectedDate) { habit in
                                HabitCardView(displayInfo: habit)
                            }
                        }
                    }

                }
                .listStyle(.plain)
                .padding(.horizontal, -16).padding(.top, -24)
            }.frame(alignment: .topLeading).padding(.horizontal, 16)
    
    }
    

    private var dailyHabitsForSelectedDate: [Habit] {
        habits.filter { habit in
            habit.occurs(on: selectedDate, calendar: calendar)
            && !habit.isWeekly
        }
    }

    private var weeklyHabitsForSelectedDate: [Habit] {
        habits.filter { habit in
            habit.isWeekly
            && calendar.isDate(selectedDate,equalTo: habit.startDate,toGranularity: .weekOfYear)
        }
    }
}

#Preview { HabitLogView() }
