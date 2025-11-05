//
//  ContentView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var navigateToChannels = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 80)
                    
                    // App Title
                    Text("MotherNurtue")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    
                    // Log In Heading
                    Text("Log In")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    
                    // Input Fields
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // New User link and Sign Up button
                    VStack(alignment: .center, spacing: 10) {
                        Button(action: {
                            // Handle new user action
                        }) {
                            Text("New User?")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .underline()
                        }
                        
                        Button(action: {
                            navigateToChannels = true
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .frame(width: 100, height: 44)
                                .background(Color(hex: "9BA897"))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $navigateToChannels) {
                ChannelsView()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "9BA897"))
            .cornerRadius(8)
            .foregroundColor(Color(hex: "5C3D2E"))
            .font(.system(size: 16, design: .rounded))
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
