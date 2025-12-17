//
//  FamilyInfoView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct FamilyInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var numberOfChildren: Int = 0
    @State private var childAges: [Int] = []
    @State private var navigateToAboutYou = false
    
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
                                Text("Step 3")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("Tell us about your family")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                Text("How many children do you have, and how old are they?")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.75))

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Number of children")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))

                                    HStack(spacing: 12) {
                                        Button(action: {
                                            if numberOfChildren > 0 {
                                                numberOfChildren -= 1
                                                // Trim ages array to match the new count (can be 0)
                                                if childAges.count > numberOfChildren {
                                                    childAges = Array(childAges.prefix(numberOfChildren))
                                                }
                                            }
                                        }) {
                                            Image(systemName: "minus")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                .frame(width: 40, height: 40)
                                                .background(Color(hex: "FDFBF6"))
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
                                                )
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)

                                        Spacer()

                                        Text("\(numberOfChildren)")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                            .frame(minWidth: 40)

                                        Spacer()

                                        Button(action: {
                                            numberOfChildren += 1
                                            // Add a new child age if needed
                                            if childAges.count < numberOfChildren {
                                                childAges.append(1)
                                            }
                                        }) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                .frame(width: 40, height: 40)
                                                .background(Color(hex: "FDFBF6"))
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
                                                )
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "E8E1D7"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                                }
                                .padding(.top, 4)

                                if numberOfChildren > 0 {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Their ages")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))

                                        ForEach(0..<numberOfChildren, id: \.self) { index in
                                            VStack(alignment: .leading, spacing: 10) {
                                                HStack {
                                                    Text("Child \(index + 1)")
                                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                        .foregroundColor(Color(hex: "5C3D2E"))
                                                    Spacer()
                                                    Text("\(index < childAges.count ? childAges[index] : 1)")
                                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                                        .foregroundColor(Color(hex: "5C3D2E"))
                                                }

                                                HStack(spacing: 10) {
                                                    Text("0")
                                                        .font(.system(size: 12, design: .rounded))
                                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))

                                                    Slider(value: Binding(
                                                        get: {
                                                            let age = index < childAges.count ? childAges[index] : 1
                                                            return Double(age)
                                                        },
                                                        set: {
                                                            while childAges.count <= index {
                                                                childAges.append(1)
                                                            }
                                                            childAges[index] = Int($0)
                                                        }
                                                    ), in: 0...18, step: 1)
                                                    .accentColor(Color(hex: "8B9A7E"))

                                                    Text("18")
                                                        .font(.system(size: 12, design: .rounded))
                                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                                                }
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                            .background(Color(hex: "E8E1D7"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
                                            )
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.top, 6)
                                }
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
                        // Save family info
                        userDataManager.profile.numberOfChildren = numberOfChildren
                        userDataManager.profile.childAges = childAges

                        navigateToAboutYou = true
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
            .navigationDestination(isPresented: $navigateToAboutYou) {
                AboutYouView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}


#Preview {
    FamilyInfoView()
}

