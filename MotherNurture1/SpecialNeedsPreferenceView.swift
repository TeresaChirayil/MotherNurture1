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
                OnboardingCenteredScrollView {
                    VStack(spacing: 16) {
                        OnboardingCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Step 7")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("Would you like to connect with parents who are raising children with special needs or unique circumstances?")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                VStack(spacing: 12) {
                                    ForEach(SpecialNeedsOption.allCases, id: \.self) { option in
                                        OnboardingOptionButton(
                                            title: option.rawValue,
                                            isSelected: selectedOption == option,
                                            action: { selectedOption = option }
                                        )
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }

                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                    }
                    .buttonStyle(OnboardingSecondaryButtonStyle())

                    Button(action: {
                        // Save special needs preference
                        userDataManager.profile.specialNeedsPreference = selectedOption?.rawValue

                        navigateToLanguagePreferences = true
                    }) {
                        HStack(spacing: 6) {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .buttonStyle(OnboardingPrimaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .navigationDestination(isPresented: $navigateToLanguagePreferences) {
                FinalTouchView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    SpecialNeedsPreferenceView()
}

