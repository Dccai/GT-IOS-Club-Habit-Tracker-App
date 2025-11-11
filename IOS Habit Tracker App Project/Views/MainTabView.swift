//
//  MainTabView.swift
//  habit tracker
//
//  Created by Nathan Bai on 11/16/25.
//
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HabitLogView()
                .tabItem {
                    Image(systemName: "checkmark.square.fill")
                    Text("Habits")
                }

            StatLogView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Stats")
                }
        }
        .tint(.blue)
    }
}
