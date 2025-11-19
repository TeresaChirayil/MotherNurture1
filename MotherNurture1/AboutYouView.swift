//
//  AboutYouView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct AboutYouView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var selectedAgeRange: AgeRange? = .eighteenToTwentyOne
    @State private var selectedTags: Set<String> = []
    @State private var navigateToInterests = false
    
    enum AgeRange: String, CaseIterable {
        case eighteenToTwentyOne = "18-21"
        case twentyTwoToTwentyFive = "22-25"
        case twentySixToTwentyNine = "26-29"
        case thirtyPlus = "30+"
    }
    
    let parentTags = [
        "First-time Parent",
        "Single parent",
        "Stay-at-home",
        "Working part-time",
        "Working full-time",
        "Parent of disabled child(ren)"
    ]
    
    var body: some View {
        ZStack {
                // Background color (beige to match other screens)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    ScrollView {
                        // Main Content
                        VStack(alignment: .leading, spacing: 30) {
                            // Question
                            Text("And what about you?")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 40)
                            
                            // Your Age
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your age:")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                HStack(spacing: 12) {
                                    ForEach(AgeRange.allCases, id: \.self) { ageRange in
                                        Button(action: {
                                            selectedAgeRange = ageRange
                                        }) {
                                            Text(ageRange.rawValue)
                                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                                .foregroundColor(selectedAgeRange == ageRange ? .white : Color(hex: "5C3D2E"))
                                                .frame(width: 80, height: 80)
                                                .background(selectedAgeRange == ageRange ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            // Parent Tags
                            VStack(alignment: .leading, spacing: 16) {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(parentTags, id: \.self) { tag in
                                        Button(action: {
                                            if selectedTags.contains(tag) {
                                                selectedTags.remove(tag)
                                            } else {
                                                selectedTags.insert(tag)
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                if selectedTags.contains(tag) {
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                                
                                                Text(tag)
                                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                                    .foregroundColor(selectedTags.contains(tag) ? .white : Color(hex: "5C3D2E"))
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 16)
                                            .background(selectedTags.contains(tag) ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                            .cornerRadius(20)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 60)
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
                            // Save about you data
                            userDataManager.profile.ageRange = selectedAgeRange?.rawValue
                            userDataManager.profile.parentTags = Array(selectedTags)
                            
                            navigateToInterests = true
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
                        .navigationDestination(isPresented: $navigateToInterests) {
                            InterestsHobbiesView()
                                .environmentObject(userDataManager)
                        }
            }
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    AboutYouView()
}

