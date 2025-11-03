//
//  LoginView.swift
//  habit tracker
//
//  Created by user940897 on 11/3/25.
//
import SwiftUI


struct LoginView: View {
    @StateObject private var userViewModel = UserViewModel()
    var body: some View {
        HStack{
            Text("Sign Out")
            Button("Sign Out Button") {
                userViewModel.signOut()
            }
        }
    }
}
