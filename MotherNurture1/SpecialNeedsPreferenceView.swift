//
//  SpecialNeedsPreferenceView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct SpecialNeedsPreferenceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var selectedOption: SpecialNeedsOption? = nil
    @State private var navigateToLanguagePreferences = false
    
    enum SpecialNeedsOption: String, CaseIterable {
        case yesConnectWithSpecialNeeds = "Yes, I'd like to connect with parents of children with special needs."
        case yesSpecificCondition = "Yes, my child has a specific condition (developmental, behavioral, or medical)."
        case openToAll = "I'm open to connecting with all parents."
        case preferNotToSay = "Prefer not to say."
    }
    
    var body: some View {
        ZStack {
                // Background color (beige to match other screens)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main Content
                    VStack(alignment: .leading, spacing: 30) {
                        // Question
                        Text("Would you like to connect with parents who are raising children with special needs or unique circumstances?")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 40)
                        
                        // Options
                        VStack(spacing: 16) {
                            ForEach(SpecialNeedsOption.allCases, id: \.self) { option in
                                Button(action: {
                                    selectedOption = option
                                }) {
                                    Text(option.rawValue)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(selectedOption == option ? .white : Color(hex: "5C3D2E"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(selectedOption == option ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                        .cornerRadius(12)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
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
                            // Save special needs preference
                            userDataManager.profile.specialNeedsPreference = selectedOption?.rawValue
                            
                            navigateToLanguagePreferences = true
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
                        .navigationDestination(isPresented: $navigateToLanguagePreferences) {
                            LanguagePreferencesView()
                                .environmentObject(userDataManager)
                        }
            }
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    SpecialNeedsPreferenceView()
}

