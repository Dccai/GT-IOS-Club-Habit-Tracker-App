import SwiftUI
import Foundation

struct HabitLogView: View {
    @Environment(\.calendar) private var calendar
    @EnvironmentObject var userViewModel : UserViewModel
    @State private var selectedDate = Date()
    @State private var selectedHabitForLog: Habit?
    @State private var selectedHabitForEdit: Habit?
    @State private var showNewHabitSheet = false
    
    
    private let cardApproxHeight: CGFloat = 107
    private let maxVisibleDailyCards = 3
    private let maxVisibleWeeklyCards = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Spacer()
                Button {
                    showNewHabitSheet = true
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 14)
            }

            Text("Habits")
                .font(.system(size: 34, weight: .bold))

            DateSelector(selectedDate: $selectedDate)
                .padding(.horizontal, -16)

            List {
                // DAILY
                Section(
                    header:
                        Text("DAILY (\(dailyHabitsForSelectedDate.count))")
                            .foregroundStyle(.black)
                            .font(.system(size: 12, weight: .medium))
                ) {
                    if dailyHabitsForSelectedDate.isEmpty {
                        HStack {
                            Spacer()
                            Text("No habits")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(dailyHabitsForSelectedDate) { habit in
                            HabitCardView(
                                displayInfo: habit,
                                onLog: {
                                    selectedHabitForLog = habit
                                },
                                onEdit: {
                                    selectedHabitForEdit = habit
                                },
                                onDelete: {
                                    Task {
                                        try? await userViewModel.deleteHabit(habit)
                                        }
                                    }
                                
                            )
                        }
                    }
                }
                // weekly stuff
                Section(
                    header:
                        Text("WEEKLY (\(weeklyHabitsForSelectedDate.count))")
                            .foregroundStyle(.black)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.top, -16)
                ) {
                    if weeklyHabitsForSelectedDate.isEmpty {
                        HStack {
                            Spacer()
                            Text("No habits")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(weeklyHabitsForSelectedDate) { habit in
                            HabitCardView(
                                displayInfo: habit,
                                onLog: {
                                    selectedHabitForLog = habit
                                },
                                onEdit: {
                                    selectedHabitForEdit = habit
                                },
                                onDelete: {
                                    Task {
                                        try? await userViewModel.deleteHabit(habit)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .listStyle(.plain)
            .padding(.horizontal, -16)
            .padding(.top, -24)
        }
        .frame(alignment: .topLeading)
        .padding(.horizontal, 16)
        // habit log sheet stuff
        .sheet(item: $selectedHabitForLog) { habit in
            HabitLogSheet(habit: habit) { newProgress in
                Task {
                    try? await userViewModel.updateHabitProgress(habit, newProgress: newProgress)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        // edit habit sheet stuff
        .sheet(item: $selectedHabitForEdit) { habit in
            NavigationStack {
                EditHabitView(habit: habit) { updatedHabit in
                    Task {
                        try? await userViewModel.updateHabit(updatedHabit)
                    }
                }
            }
        }
        // new habit sheet stuff
        .sheet(isPresented: $showNewHabitSheet) {
            NewHabitView { newHabit in
                Task {
                    try? await userViewModel.addHabit(newHabit)
                }
                selectedDate = Date() // Reset to today so you see the new habit
            }
        }
    }

    // filtering

    private var dailyHabitsForSelectedDate: [Habit] {
        userViewModel.habits.filter { habit in
            habit.occurs(on: selectedDate, calendar: calendar)
            && !habit.isWeekly
        }
    }

    private var weeklyHabitsForSelectedDate: [Habit] {
        userViewModel.habits.filter { habit in
            guard habit.isWeekly else { return false }
            guard selectedDate >= calendar.startOfDay(for: habit.startDate) else {
                return false
            }
            let selectedWeekStart = calendar.startOfWeek(containing: selectedDate)
            let habitWeekStart = calendar.startOfWeek(containing: habit.startDate)
            return selectedWeekStart >= habitWeekStart
        }
    }

    private var dailyListHeight: CGFloat {
        heightForList(count: dailyHabitsForSelectedDate.count,
                      maxVisible: maxVisibleDailyCards)
    }

    private var weeklyListHeight: CGFloat {
        heightForList(count: weeklyHabitsForSelectedDate.count,
                      maxVisible: maxVisibleWeeklyCards)
    }

    private func heightForList(count: Int, maxVisible: Int) -> CGFloat {
        guard count > 0 else { return 150 }
        let visibleRows = min(count, maxVisible)
        return CGFloat(visibleRows) * cardApproxHeight
    }
}

#Preview {
    NavigationStack {
        HabitLogView()
    }
}
