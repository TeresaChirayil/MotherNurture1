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
                OnboardingCenteredScrollView {
                    VStack(spacing: 16) {
                        OnboardingCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Step 4")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("And what about you?")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Your age")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))

                                    HStack(spacing: 12) {
                                        ForEach(AgeRange.allCases, id: \.self) { ageRange in
                                            Button(action: {
                                                selectedAgeRange = ageRange
                                            }) {
                                                Text(ageRange.rawValue)
                                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                    .foregroundColor(selectedAgeRange == ageRange ? .white : Color(hex: "5C3D2E"))
                                                    .frame(width: 72, height: 72)
                                                    .background(selectedAgeRange == ageRange ? Color(hex: "8B9A7E") : Color(hex: "E8E1D7"))
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color(hex: "5C3D2E").opacity(selectedAgeRange == ageRange ? 0.0 : 0.10), lineWidth: 1)
                                                    )
                                                    .clipShape(Circle())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.top, 4)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Tags")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))

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
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 12, weight: .bold))
                                                            .foregroundColor(.white)
                                                    }

                                                    Text(tag)
                                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                        .foregroundColor(selectedTags.contains(tag) ? .white : Color(hex: "5C3D2E"))
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .background(selectedTags.contains(tag) ? Color(hex: "8B9A7E") : Color(hex: "E8E1D7"))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(Color(hex: "5C3D2E").opacity(selectedTags.contains(tag) ? 0.0 : 0.10), lineWidth: 1)
                                                )
                                                .cornerRadius(14)
                                            }
                                            .buttonStyle(.plain)
                                        }
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
                        // Save about you data
                        userDataManager.profile.ageRange = selectedAgeRange?.rawValue
                        userDataManager.profile.parentTags = Array(selectedTags)

                        navigateToInterests = true
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

