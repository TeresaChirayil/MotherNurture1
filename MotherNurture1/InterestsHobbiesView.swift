//
//  InterestsHobbiesView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct InterestsHobbiesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var selectedInterests: Set<String> = []
    @State private var navigateToConnectionPreference = false
    
    let interests = [
        "Reading",
        "Cooking",
        "Arts & Crafts",
        "Traveling",
        "Exercising",
        "Gardening",
        "Anything!"
    ]
    
    var body: some View {
        ZStack {
                // Background color (beige to match other screens)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        // Main Content
                        VStack(alignment: .leading, spacing: 20) {
                            // Question
                            Text("What would you enjoy doing in your free time?")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 40)
                            
                            // Instruction
                            Text("More than one option is possible.")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 40)
                            
                            // Interest Options
                            VStack(spacing: 16) {
                                ForEach(interests, id: \.self) { interest in
                                    Button(action: {
                                        if selectedInterests.contains(interest) {
                                            selectedInterests.remove(interest)
                                        } else {
                                            selectedInterests.insert(interest)
                                        }
                                    }) {
                                        Text(interest)
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                            .foregroundColor(selectedInterests.contains(interest) ? .white : Color(hex: "5C3D2E"))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(selectedInterests.contains(interest) ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                            .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    
                    // Bottom Navigation
                    HStack {
                        // Previous Button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("Previous")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Next Button
                        Button(action: {
                            // Save interests
                            userDataManager.profile.interests = Array(selectedInterests)
                            
                            navigateToConnectionPreference = true
                        }) {
                            HStack(spacing: 4) {
                                Text("Next")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                        .navigationDestination(isPresented: $navigateToConnectionPreference) {
                            ConnectionPreferenceView()
                                .environmentObject(userDataManager)
                        }
            }
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    InterestsHobbiesView()
}

