import SwiftUI

struct NewHabitView: View {
    @Environment(\.dismiss) private var dismiss

    // called when user taps "Add"
    var onAdd: (Habit) -> Void

    // var declaration

    @State private var habitName: String = ""
    @State private var label: String = ""
    @State private var selectedColorIndex: Int = 0
    @State private var goalNumber: String = ""
    @State private var unit: String = ""
    @State private var repeatOption: RepeatPickerOption = .daily
    @State private var showCustomDaysSheet = false
    @State private var selectedDays: Set<Weekday> = [.monday, .friday]

    private let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // Default init so you can still call `NewHabitView()` in previews / sheets
    init(onAdd: @escaping (Habit) -> Void = { _ in }) {
        self.onAdd = onAdd
    }

    // MARK: - Derived values

    private var customDaysText: String {
        if selectedDays.isEmpty {
            return "No days selected"
        }
        let sorted = selectedDays.sorted { $0.rawValue < $1.rawValue }
        let names = sorted.compactMap { day -> String? in
            let idx = day.rawValue - 1
            guard idx >= 0 && idx < weekdaySymbols.count else { return nil }
            return weekdaySymbols[idx]
        }
        return names.joined(separator: ", ")
    }

    private var repeatRule: HabitRepeat {
        switch repeatOption {
        case .daily:
            return .daily
        case .weekdays:
            return .weekdays
        case .weekends:
            return .weekends
        case .weekly:
            return .weekly
        case .custom:
            return .customWeekdays(selectedDays)
        }
    }

    private var isWeeklyFlag: Bool {
        repeatOption == .weekly
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
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        }
    }

    private func colorRow(start: Int, end: Int) -> some View {
        HStack(spacing: 16) {
            ForEach(start..<end, id: \.self) { index in
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
        }
    }

    @ViewBuilder
    private var goalSection: some View {
        Section {
            HStack {
                Text("Goal")
                Spacer()
                TextField("Number", text: $goalNumber)
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
    private var repeatSection: some View {
        Section(header: Text("REPEAT")) {
            let options = RepeatPickerOption.allCases
            ForEach(options.indices, id: \.self) { idx in
                let option = options[idx]

                HStack {
                    Text(option.rawValue)
                        .foregroundColor(.primary)

                    Spacer()

                    if option == .custom {
                        Text(customDaysText)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    if option == repeatOption {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                nameSection
                colorSection
                goalSection
                repeatSection
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addHabit()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showCustomDaysSheet) {
                CustomDaysView(selectedDays: $selectedDays)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // actions for new habit

    private func addHabit() {
        let goalValue = Int(goalNumber) ?? 0
        let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            dismiss()
            return
        }

        let newHabit = Habit(
            name: trimmedName,
            label: label,
            progress: 0,
            colorIndex: selectedColorIndex,
            goal: goalValue,
            unit: unit,
            startDate: Date(),
            repeatRule: repeatRule,
            isWeekly: isWeeklyFlag
        )

        onAdd(newHabit)
        dismiss()
    }
}

#Preview {
    NewHabitView()
}
