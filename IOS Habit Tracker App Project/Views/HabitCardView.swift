
//
//  HabitCardView.swift
//  habit tracker
//
//  Created by Nathan Bai on 10/30/25.
//
import SwiftUI

let sampleHabit = Habit(
    name: "Call Family",
    label: "📞",
    progress: 0,
    colorIndex: 1,
    goal: 1,
    unit: "time",
    startDate: .now,
    repeatRule: .daily,
    isWeekly: false
)

struct HabitCardView: View {
    var displayInfo: Habit
    var onLog: () -> Void = {}
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    
    var body: some View {
            HStack(spacing: 10){
                VStack{
                    HStack{
                        ZStack{
                            Circle().fill(colors[displayInfo.colorIndex].opacity(0.4))
                            Text(displayInfo.label)
                        }.frame(width: 48, height: 48)
                            VStack(alignment: .leading){
                                Text(displayInfo.name).font(.system(size: 12, weight: .medium))
                                HStack(spacing: -1){
                                    Text("\(displayInfo.progress)/").font(.system(size: 32, weight: .regular, design: .monospaced))
                                    VStack(alignment: .leading){
                                        Text("\(displayInfo.goal)")
                                        Text("\(displayInfo.unit)")
                                    }.font(.system(size: 12, weight: .bold, design: .monospaced))
                                }
                            }
                            Spacer()
                            Button(action: onLog) {
                                                HStack(spacing: 2) {
                                                    Image(systemName: "plus")
                                                    Text("Log")
                                                }
                                                .foregroundStyle(.white)
                                                .font(.system(size: 12))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.blue)
                                                .clipShape(Capsule())
                                            }
                                            .buttonStyle(.plain)
                        
                    }
                }
            }.padding(.vertical, 12).contentShape(Rectangle()).swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .tint(.orange)
            }
    }
}

#Preview { HabitCardView(displayInfo: sampleHabit) }
