//
//  Habit.swift
//  habit tracker
//
//  Created by Nathan Bai on 10/30/25.
//

import Foundation
import SwiftUI

struct Habit: Identifiable, Codable {
    var id: UUID = UUID()
    
    var name: String
    var label: String //emoji
    var hex: String
    var color: Color{ Color(hex: hex) }
    var progress: Int
    var goal: Int
    var unit: String
    
    
}

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r, g, b, a: Double
        switch s.count {
        case 6:
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8)  & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1.0
        case 8:
            r = Double((value >> 24) & 0xFF) / 255.0
            g = Double((value >> 16) & 0xFF) / 255.0
            b = Double((value >> 8)  & 0xFF) / 255.0
            a = Double(value & 0xFF) / 255.0
        default:
            (r,g,b,a) = (0,0,0,1) // fallback
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

    
