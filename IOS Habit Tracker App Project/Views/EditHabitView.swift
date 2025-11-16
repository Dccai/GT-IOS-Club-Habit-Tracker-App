import SwiftUI

// Helper enum just for the picker UI
enum RepeatPickerOption: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case weekly = "Weekly"
    case custom = "Custom"

    var id: Self { self }
}

struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss

    let habit: Habit
    let onSave: (Habit) -> Void
//state variables
    @State private var habitName: String
    @State private var label: String
    @State private var selectedColorIndex: Int
    @State private var goalText: String
    @State private var unit: String
    @State private var repeatOption: RepeatPickerOption
    @State private var customWeekdays: Set<Weekday>
    @State private var startDate: Date
    @State private var isWeekly: Bool
    @State private var showCustomDaysSheet = false

    private let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    //init

    init(habit: Habit, onSave: @escaping (Habit) -> Void) {
        self.habit = habit
        self.onSave = onSave

        _habitName = State(initialValue: habit.name)
        _label = State(initialValue: habit.label)
        _selectedColorIndex = State(initialValue: habit.colorIndex)
        _goalText = State(initialValue: String(habit.goal))
        _unit = State(initialValue: habit.unit)
        _startDate = State(initialValue: habit.startDate)
        _isWeekly = State(initialValue: habit.isWeekly)

        let mapping: (RepeatPickerOption, Set<Weekday>) = {
            switch habit.repeatRule {
            case .daily:
                return (.daily, [])
            case .weekdays:
                return (.weekdays, [])
            case .weekends:
                return (.weekends, [])
            case .weekly:
                return (.weekly, [])
            case .customWeekdays(let days):
                return (.custom, days)
            }
        }()

        _repeatOption = State(initialValue: mapping.0)
        _customWeekdays = State(initialValue: mapping.1)
    }

    // derived values

    private var finalRepeatRule: HabitRepeat {
        switch repeatOption {
        case .daily: return .daily
        case .weekdays: return .weekdays
        case .weekends: return .weekends
        case .weekly: return .weekly
        case .custom: return .customWeekdays(customWeekdays)
        }
    }

    private func customDaysLabel(from days: Set<Weekday>) -> String {
        if days.isEmpty {
            return "No days selected"
        }
        let sorted = days.sorted { $0.rawValue < $1.rawValue }

        var parts: [String] = []
        for day in sorted {
            let idx = day.rawValue - 1
            if idx >= 0 && idx < weekdaySymbols.count {
                parts.append(weekdaySymbols[idx])
            }
        }
        return parts.joined(separator: ", ")
    }

    // parts of view

    @ViewBuilder
    private var nameSection: some View {
        Section {
            HStack {
                Text("Name")
                Spacer()
                TextField("Habit", text: $habitName)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Label")
                Spacer()
                TextField("Emoji", text: $label)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
                    .textInputAutocapitalization(.never)
            }
        }
    }

    @ViewBuilder
    private var colorSection: some View {
        Section {
            VStack(spacing: 16) {
                colorRow(start: 0, end: 6)
                colorRow(start: 6, end: 12)
            }
            .padding(.vertical, 8)
        }
    }

    private func colorRow(start: Int, end: Int) -> some View {
        HStack(spacing: 16) {
            ForEach(start..<end, id: \.self) { index in
                colorCircle(at: index)
            }
        }
    }

    private func colorCircle(at index: Int) -> some View {
        Circle()
            .fill(colors[index])
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .strokeBorder(Color.blue, lineWidth: selectedColorIndex == index ? 2 : 0)
            )
            .onTapGesture {
                selectedColorIndex = index
            }
    }

    @ViewBuilder
    private var goalSection: some View {
        Section {
            HStack {
                Text("Goal")
                Spacer()
                TextField("Number", text: $goalText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Unit")
                Spacer()
                TextField("ex. oz, hr, min", text: $unit)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var startDateSection: some View {
        Section {
            HStack {
                Text("Start Date")
                Spacer()
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(.blue)
            }
        }
    }

    @ViewBuilder
    private var repeatSection: some View {
        Section(header: Text("REPEAT")) {
            let options = RepeatPickerOption.allCases
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]

                RepeatOptionRow(
                    option: option,
                    isSelected: option == repeatOption,
                    customText: option == .custom ? customDaysLabel(from: customWeekdays) : nil
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    repeatOption = option
                    if option == .custom {
                        showCustomDaysSheet = true
                    }
                }
            }
        }
    }

    // body view

    var body: some View {
        List {
            nameSection
            colorSection
            goalSection
            startDateSection
            repeatSection
        }
        .navigationTitle("Edit Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveHabit()
                }
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showCustomDaysSheet) {
            CustomDaysView(selectedDays: $customWeekdays)
        }
    }

    // habit actions

    private func saveHabit() {
        let goalValue = Int(goalText) ?? habit.goal

        let updatedHabit = Habit(
            id: habit.id,
            name: habitName,
            label: label,
            progress: habit.progress,
            colorIndex: selectedColorIndex,
            goal: goalValue,
            unit: unit,
            startDate: startDate,
            repeatRule: finalRepeatRule,
            isWeekly: isWeekly
        )

        onSave(updatedHabit)
        dismiss()
    }
}

//Repeat functionality

struct RepeatOptionRow: View {
    let option: RepeatPickerOption
    let isSelected: Bool
    let customText: String?

    var body: some View {
        HStack {
            Text(option.rawValue)
                .foregroundColor(.primary)

            Spacer()

            if let customText, option == .custom {
                Text(customText)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
    }
}

// custom day selection view

struct CustomDaysView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDays: Set<Weekday>

    private let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Weekday.allCases, id: \.self) { day in
                    Button {
                        toggle(day)
                    } label: {
                        HStack {
                            Text(weekdaySymbols[day.rawValue - 1])
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedDays.contains(day) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Custom Days")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .tint(.blue)
                }
            }
        }
    }

    private func toggle(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}


#Preview {
    let habit = Habit(
        name: "Drink Water",
        label: "💧",
        progress: 0,
        colorIndex: 3,
        goal: 8,
        unit: "glasses",
        startDate: Date(),
        repeatRule: .daily,
        isWeekly: false
    )

    return EditHabitView(habit: habit) { _ in }
}
