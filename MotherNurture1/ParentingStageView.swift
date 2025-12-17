//
//  ParentingStageView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct ParentingStageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var selectedOption: ParentingOption? = nil
    @State private var navigateToFamilyInfo = false
    
    enum ParentingOption: String, CaseIterable {
        case expecting = "Expecting"
        case haveChildren = "Have children"
        case both = "Both"
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
                                Text("Step 2")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("Are you currently expecting, or do you already have children?")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .multilineTextAlignment(.leading)

                                VStack(spacing: 12) {
                                    ForEach(ParentingOption.allCases, id: \.self) { option in
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
                        // Save parenting stage
                        userDataManager.profile.parentingStage = selectedOption?.rawValue

                        navigateToFamilyInfo = true
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
            .navigationDestination(isPresented: $navigateToFamilyInfo) {
                FamilyInfoView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ParentingStageView()
}

