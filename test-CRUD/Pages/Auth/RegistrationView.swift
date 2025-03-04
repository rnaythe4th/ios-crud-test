//
//  RegistrationView.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    private let accentColor = Color.blue
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }
            
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    inputFields
                    actionButtons
                }
                .padding(24)
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.2))
            
            Text("Create your account")
                .font(.system(size: 24, weight: .semibold))
        }
    }
    
    private var inputFields: some View {
        VStack(spacing: 20) {
            CustomTextField(
                text: $email,
                placeholder: "Email",
                icon: "envelope",
                isSecure: false
            )
            
            CustomTextField(
                text: $password,
                placeholder: "Password",
                icon: "lock",
                isSecure: true
            )
            
            CustomTextField(
                text: $confirmPassword,
                placeholder: "Repeat password",
                icon: "lock",
                isSecure: true
            )
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: handleRegistration) {
                Text("Sign Up")
                    .authButtonStyle(backgroundColor: accentColor)
            }
            
            NavigationLink {
                LoginView()
            } label: {
                Text("Already have an account? Sign In")
                    .authButtonStyle(
                        backgroundColor: .clear,
                        foregroundColor: accentColor,
                        borderColor: accentColor
                    )
            }
        }
    }
    
    private func handleRegistration() {
        hideKeyboard()
        authViewModel.signUp(
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
    }
}

private func hideKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}

fileprivate struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let isSecure: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

fileprivate extension Text {
    func authButtonStyle(
        backgroundColor: Color,
        foregroundColor: Color = .white,
        borderColor: Color = .clear
    ) -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .cornerRadius(12)
    }
}
