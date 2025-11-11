//
//  DateSelector.swift
//  habit tracker
//
//  Created by Nathan Bai on 11/7/25.
//

import SwiftUI

struct DateSelector: View {
    @Environment(\.calendar) private var calendar

    @Binding var selectedDate: Date
    @State private var weekAnchor: Date

    @State private var drag: CGFloat = 0
    private let rowHeight: CGFloat = 56
    private let stackSpacing: CGFloat = 44
    private let swipeThresholdRatio: CGFloat = 0.30
    
    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        _weekAnchor = State(initialValue: Calendar.current.startOfWeek(containing: selectedDate.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 6){
            Divider()
            VStack(spacing: 2) {
                HStack(spacing: 0) {
                    ForEach(datesInWeek(weekAnchor), id: \.self) { date in
                        Text(weekdayLetter(for: date))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(weekdayTextColor(for: date))
                            .frame(maxWidth: .infinity)
                    }
                }.padding(.horizontal, 4).padding(.top, 10)

                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.systemGray5))
                        .opacity(bgOpacity)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .offset(y: drag)

                    WeekStrip(
                        weekStart: shift(weekAnchor, byWeeks: -1),
                        selectedDate: selectedDate,
                        dimmed: true
                    ) { selectedDate = $0 }
                    .offset(y: drag - stackSpacing)
                    .blur(radius: blur(forOffset: drag - stackSpacing))
                    .opacity(opacity(forOffset: drag - stackSpacing))

                    WeekStrip(
                        weekStart: weekAnchor,
                        selectedDate: selectedDate,
                        dimmed: false
                    ) { selectedDate = $0 }
                    .offset(y: drag)
                    .blur(radius: 0)
                    .opacity(1)

                    WeekStrip(
                        weekStart: shift(weekAnchor, byWeeks: +1),
                        selectedDate: selectedDate,
                        dimmed: true
                    ) { selectedDate = $0 }
                    .offset(y: drag + stackSpacing)
                    .blur(radius: blur(forOffset: drag + stackSpacing))
                    .opacity(opacity(forOffset: drag + stackSpacing))
                }
                .frame(height: rowHeight)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .contentShape(Rectangle())
                .padding(.horizontal, 4)
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            drag = value.translation.height
                        }
                        .onEnded { value in
                            let threshold = rowHeight * swipeThresholdRatio
                            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.88, blendDuration: 0.15)) {
                                if value.translation.height <= -threshold {
                                    weekAnchor = shift(weekAnchor, byWeeks: +1)
                                    selectedDate = shift(selectedDate, byWeeks: +1)
                                } else if value.translation.height >= threshold {
                                    weekAnchor = shift(weekAnchor, byWeeks: -1)
                                    selectedDate = shift(selectedDate, byWeeks: -1)
                                }
                                drag = 0
                            }
                        }
                )
                .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.15),
                           value: drag)

            }
            .padding(.horizontal)
            .onAppear {
                weekAnchor = calendar.startOfWeek(containing: selectedDate)
            }
            Divider()
            
        }.background(Color(white: 0.99))
    }

    private func datesInWeek(_ start: Date) -> [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    private func weekdayLetter(for date: Date) -> String {
        let wd = calendar.component(.weekday, from: date)
        return calendar.veryShortWeekdaySymbols[wd - 1]
    }
    private func weekdayTextColor(for date: Date) -> Color {
        isSelected(date) ? .red : .secondary
    }

    private func shift(_ date: Date, byWeeks w: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: w, to: date) ?? date
    }
    private func blur(forOffset off: CGFloat) -> CGFloat {
        8 * min(1, abs(off) / rowHeight)
    }
    private func opacity(forOffset off: CGFloat) -> Double {
        Double(1 - 0.35 * min(1, abs(off) / rowHeight))
    }
    private var bgOpacity: Double {
        let p = min(1, abs(drag) / rowHeight)
        return Double(p)
    }
}

private struct WeekStrip: View {
    @Environment(\.calendar) private var calendar
    let weekStart: Date
    let selectedDate: Date
    let dimmed: Bool
    let onSelect: (Date) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(dates, id: \.self) { date in
                VStack {
                    Button {
                        onSelect(date)
                    } label: {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(dimmed ? .secondary : .black)
                            .frame(maxWidth: 41, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected(date) ? Color(.systemGray5) : .clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var dates: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    private func isSelected(_ d: Date) -> Bool {
        calendar.isDate(d, inSameDayAs: selectedDate)
    }
}


extension Calendar {
    func startOfWeek(containing day: Date) -> Date {
        dateInterval(of: .weekOfYear, for: day)?.start ?? startOfDay(for: day)
    }
}


