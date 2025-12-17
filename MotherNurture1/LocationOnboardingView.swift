//
//  LocationOnboardingView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct LocationOnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var zipcode: String = ""
    @State private var city: String = ""
    @State private var navigateToParentingStage = false
    
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
                                Text("To get started")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("Where are you located?")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .multilineTextAlignment(.leading)

                                VStack(alignment: .leading, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Zipcode")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))

                                        TextField("Enter zipcode", text: $zipcode)
                                            .textFieldStyle(OnboardingTextFieldStyle())
                                            .keyboardType(.numberPad)
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("City")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))

                                        TextField("Enter city", text: $city)
                                            .textFieldStyle(OnboardingTextFieldStyle())
                                            .textInputAutocapitalization(.words)
                                            .disableAutocorrection(true)
                                    }
                                }
                                .padding(.top, 4)
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
                        // Save location data
                        userDataManager.profile.zipcode = zipcode.isEmpty ? nil : zipcode
                        userDataManager.profile.town = city.isEmpty ? nil : city

                        navigateToParentingStage = true
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
            .navigationDestination(isPresented: $navigateToParentingStage) {
                ParentingStageView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// Custom TextField Style for Location
struct LocationTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "D4C4B0")) // Light brown background
            .cornerRadius(8)
            .foregroundColor(Color(hex: "5C3D2E"))
            .font(.system(size: 16, design: .rounded))
    }
}

#Preview {
    NavigationStack {
        LocationOnboardingView()
    }
}

