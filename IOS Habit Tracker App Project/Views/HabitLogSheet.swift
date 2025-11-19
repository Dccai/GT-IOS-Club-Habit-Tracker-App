import SwiftUI
import Foundation

struct HabitLogSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentValue: String
    
    let habit: Habit
    let onSave: (Int) -> Void
    
    init(habit: Habit, onSave: @escaping (Int) -> Void) {
        self.habit = habit
        self.onSave = onSave
        _currentValue = State(initialValue: String(habit.progress))
    }
    
    private func appendNumber(_ number: String) {
        if currentValue == "0" {
            currentValue = number
        } else {
            currentValue += number
        }
    }
    
    private func deleteLastDigit() {
        if currentValue.count > 1 {
            currentValue.removeLast()
        } else {
            currentValue = "0"
        }
    }
    
    private func clearValue() {
        currentValue = "0"
    }
    
    private func incrementValue() {
        if let value = Int(currentValue) {
            currentValue = String(value + 1)
        }
    }
    
    private func decrementValue() {
        if let value = Int(currentValue), value > 0 {
            currentValue = String(value - 1)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Log: \(habit.name)")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Button(action: {
                    saveAndDismiss()
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            .background(Color(UIColor.systemGray6))
            
            // value display
            HStack(spacing: 30) {
                Button(action: { decrementValue() }) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "minus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
                
                VStack(spacing: 10) {
                    Text(currentValue)
                        .font(.system(size: 72, weight: .regular))
                        .frame(width: 180, height: 100)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(8)
                    
                    Text("/ \(habit.goal) \(habit.unit)")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                }
                
                Button(action: { incrementValue() }) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.bottom, 30)
            
            // num pad
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    NumberButton(text: "1", onTap: { appendNumber("1") })
                    NumberButton(text: "2", letters: "ABC", onTap: { appendNumber("2") })
                    NumberButton(text: "3", letters: "DEF", onTap: { appendNumber("3") })
                }
                HStack(spacing: 1) {
                    NumberButton(text: "4", letters: "GHI", onTap: { appendNumber("4") })
                    NumberButton(text: "5", letters: "JKL", onTap: { appendNumber("5") })
                    NumberButton(text: "6", letters: "MNO", onTap: { appendNumber("6") })
                }
                HStack(spacing: 1) {
                    NumberButton(text: "7", letters: "PQRS", onTap: { appendNumber("7") })
                    NumberButton(text: "8", letters: "TUV", onTap: { appendNumber("8") })
                    NumberButton(text: "9", letters: "WXYZ", onTap: { appendNumber("9") })
                }
                HStack(spacing: 1) {
                    DeleteButton(isBackspace: true, onTap: { deleteLastDigit() })
                    NumberButton(text: "0", onTap: { appendNumber("0") })
                    DeleteButton(isBackspace: true, onTap: { deleteLastDigit() })
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGray6))
        .onDisappear {
            saveAndDismiss()
        }
    }
    
    private func saveAndDismiss() {
        if let value = Int(currentValue) {
            onSave(value)
        }
    }
}

struct NumberButton: View {
    let text: String
    var letters: String = ""
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(text)
                    .font(.system(size: 28))
                    .foregroundColor(.black)
                if !letters.isEmpty {
                    Text(letters)
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
        }
    }
}

struct DeleteButton: View {
    var isBackspace: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: isBackspace ? "delete.left" : "xmark")
                .font(.system(size: 20))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(UIColor.systemGray4))
        }
    }
}

#Preview {
    HabitLogSheet(
        habit: Habit(
            name: "Drink Water",
            label: "💧",
            progress: 5,
            colorIndex: 0,
            goal: 8,
            unit: "cups",
            startDate: Date(),
            repeatRule: .daily,
            isWeekly: false
        ),
        onSave: { newValue in
            print("Saved new value: \(newValue)")
        }
    )
}
