//
//  StatLogView.swift
//  habit tracker
//
//  Created by Nathan Bai on 11/16/25.
//
import SwiftUI

struct StatLogView: View {
    @Environment(\.calendar) private var calendar
    @State private var selectedDate = Date()
    @State private var showNewHabitSheet = false
    @State private var habits = sampleHabits
    
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
            
            Text("Stats")
                .font(.system(size: 34, weight: .bold))
            
            DateSelector(selectedDate: $selectedDate)
                .padding(.horizontal, -16)
            
            List {
                Section(
                    header: Text("DAILY (\(dailyHabitsForSelectedDate.count))")
                        .foregroundStyle(.black)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.bottom, -16)
                ) {
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
                            StatCardView(displayInfo: habit)
                        }
                    }
                }
                
                Section(
                    header: Text("WEEKLY (\(weeklyHabitsForSelectedDate.count))")
                        .foregroundStyle(.black)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.vertical, -16)
                ) {
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
                            StatCardView(displayInfo: habit)
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
        //new habit sheet stuff
        .sheet(isPresented: $showNewHabitSheet) {
            NewHabitView { newHabit in
                habits.append(newHabit)
                selectedDate = Date()
            }
        }
    }
    
    private var dailyHabitsForSelectedDate: [Habit] {
        habits.filter { habit in
            habit.occurs(on: selectedDate, calendar: calendar)
            && !habit.isWeekly
        }
    }
    
    private var weeklyHabitsForSelectedDate: [Habit] {
        habits.filter { habit in
            guard habit.isWeekly else { return false }
            guard selectedDate >= calendar.startOfDay(for: habit.startDate) else {
                return false
            }
            let selectedWeekStart = calendar.startOfWeek(containing: selectedDate)
            let habitWeekStart = calendar.startOfWeek(containing: habit.startDate)
            return selectedWeekStart >= habitWeekStart
        }
    }
}

#Preview { StatLogView() }
