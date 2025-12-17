//
//  ConnectionPreferenceView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct ConnectionPreferenceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var selectedOption: ConnectionType? = nil
    @State private var navigateToSpecialNeedsPreference = false
    
    enum ConnectionType: String, CaseIterable {
        case oneOnOne = "1-on-1"
        case smallCircle = "Small Circle"
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
                                Text("Step 6")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("Would you like to start with a 1-on-1 buddy or a small parent circle?")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                VStack(spacing: 12) {
                                    ForEach(ConnectionType.allCases, id: \.self) { option in
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
                        // Save connection preference
                        userDataManager.profile.connectionPreference = selectedOption?.rawValue

                        navigateToSpecialNeedsPreference = true
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
            .navigationDestination(isPresented: $navigateToSpecialNeedsPreference) {
                SpecialNeedsPreferenceView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ConnectionPreferenceView()
}

