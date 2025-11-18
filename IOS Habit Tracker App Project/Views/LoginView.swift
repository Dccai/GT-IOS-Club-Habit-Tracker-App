//
//  LoginView.swift
//  habit tracker
//
//  Created by user940897 on 11/3/25.
//
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var userViewModel : UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    var body: some View {
        NavigationStack {
            VStack(spacing:20) {
                Spacer()
                Text(isSignUp ? "Create Account" : "Welcome Back")
                    .font(.system(size:34,weight: .bold))
                    .padding(.bottom,20)
                if isSignUp {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal)
                }
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                SecureField("Password", text:$password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                Button(action: {
                    Task {
                        await handleAuth()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(isSignUp ? "Sign Up" : "Log In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading)
                
                Button(action: {
                    isSignUp.toggle()
                    errorMessage = ""
                }) {
                    Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .foregroundStyle(.blue)
                }
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    private func handleAuth() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all of the fields"
            return
        }
        if isSignUp && name.isEmpty {
            errorMessage = "Can you please enter your name"
            return
        }
        isLoading = true
        errorMessage = ""
        do {
            if isSignUp {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let newUser = User(id: result.user.uid, name: name, email: email)
                try await userViewModel.addUser(user: newUser)
                await userViewModel.fetchUser()
                dismiss()
            } else {
                try await Auth.auth().signIn(withEmail: email, password: password)
                await userViewModel.fetchUser()
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(UserViewModel())
}
