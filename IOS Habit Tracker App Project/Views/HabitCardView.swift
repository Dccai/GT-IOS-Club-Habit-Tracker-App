//
//  HabitCardView.swift
//  habit tracker
//
//  Created by Nathan Bai on 10/30/25.
//
import SwiftUI

let placeholderHabit = Habit(
    name: "Drink Water",
    label: "💧",
    hex: "4EABF3",
    progress: 5,
    goal: 104,
    unit: "OZ"
)


struct HabitCardView: View {
    var displayInfo: Habit
    
    var body: some View {
            HStack(spacing: 10){
                VStack{
                    HStack{
                        ZStack{
                            Circle().fill(displayInfo.color.opacity(0.4))
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
                            NavigationLink {} label: {
                                HStack(spacing: 2){
                                    Image(systemName: "plus")
                                    Text("Log")
                                }.foregroundStyle(.white)
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                    }
                    Divider().padding(.leading, 58).padding(.trailing, -16)
                }
            }.padding(.horizontal, 16).padding(.top, 24)
    }
}

#Preview { HabitCardView(displayInfo: placeholderHabit) }
