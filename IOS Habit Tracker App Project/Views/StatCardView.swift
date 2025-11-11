//
//  StatCardView.swift
//  habit tracker
//
//  Created by Nathan Bai on 11/16/25.
//
import SwiftUI

struct StatCardView: View {
    var displayInfo: Habit
    var onLog: () -> Void = {}
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    
    var body: some View {
        let percent = displayInfo.goal == 0 ? 100 : Int((Double(displayInfo.progress) / Double(displayInfo.goal) * 100).rounded())
        
            HStack(spacing: 10){
                VStack{
                    HStack{
                        ZStack{
                            Circle().fill(colors[displayInfo.colorIndex].opacity(0.4))
                            Text(displayInfo.label)
                        }.frame(width: 48, height: 48)
                        Text(displayInfo.name).font(.system(size: 12, weight: .medium))
                        Spacer()
                        Text("\(percent)%").font(.system(size: 32, weight: .regular, design: .monospaced))
                        
                        
                    }
                }
            }.padding(.vertical, 12).contentShape(Rectangle())
    }
}

#Preview { StatCardView(displayInfo: sampleHabit) }
