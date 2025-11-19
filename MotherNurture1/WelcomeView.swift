//
//  WelcomeView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var navigateToLocation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color (beige to match other screens)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                // Top Navigation - Back button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            Text("Back")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 60)
                
                Spacer()
                
                // Main Content
                VStack(spacing: 24) {
                    // Headline
                    Text("Here, mothers grow together.")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 40)
                    
                    // Subtitle
                    Text("Let's get to know you so we can connect you with your village!")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Start Button
                Button(action: {
                    navigateToLocation = true
                }) {
                    Text("Start")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "9BA897"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                }
                .navigationDestination(isPresented: $navigateToLocation) {
                    LocationOnboardingView()
                        .environmentObject(userDataManager)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}

