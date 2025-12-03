//
//  SignUpView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var email: String = ""
    @State private var showDatePicker: Bool = false
    @State private var navigateToWelcome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color (beige to match other screens)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    // Back button
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "8B9A7E"))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Title
                    Text("Sign Up")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    
                    Spacer()
                    
                    // Spacer to balance the back button
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // First Name Field
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(SignUpTextFieldStyle())
                        
                        // Last Name Field
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(SignUpTextFieldStyle())
                        
                        // Date of Birth Field
                        HStack {
                            Text("Date of Birth")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            Spacer()
                            
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                Text(dateFormatter.string(from: dateOfBirth))
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "D4C4B0"))
                                    .cornerRadius(20)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding()
                        .background(Color(hex: "D4C4B0"))
                        .cornerRadius(8)
                        
                        if showDatePicker {
                            DatePicker(
                                "Date of Birth",
                                selection: $dateOfBirth,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .accentColor(Color(hex: "5C3D2E"))
                            .padding()
                            .background(Color(hex: "D4C4B0"))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                            .padding(.top, -10)
                        }
                        
                        // Email Field
                        TextField("Email", text: $email)
                            .textFieldStyle(SignUpTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                
                // Sign Up Button
                Button(action: {
                    // Save sign-up data to UserDataManager
                    userDataManager.profile.firstName = firstName.isEmpty ? nil : firstName
                    userDataManager.profile.lastName = lastName.isEmpty ? nil : lastName
                    userDataManager.profile.dateOfBirth = dateOfBirth
                    userDataManager.profile.email = email.isEmpty ? nil : email
                    
                    navigateToWelcome = true
                }) {
                    Text("Sign up")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "8B9A7E"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                }
                .navigationDestination(isPresented: $navigateToWelcome) {
                    WelcomeView()
                        .environmentObject(userDataManager)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
}

// Custom TextField Style for Sign Up
struct SignUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "D4C4B0")) // Light brown background
            .cornerRadius(8)
            .foregroundColor(Color(hex: "5C3D2E"))
            .font(.system(size: 16, design: .rounded))
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(UserDataManager.shared)
    }
}
