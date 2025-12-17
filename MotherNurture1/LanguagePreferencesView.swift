//
//  LanguagePreferencesView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct LanguagePreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var selectedLanguages: Set<String> = []
    @State private var otherLanguage: String = ""
    @State private var navigateToFinalTouch = false
    
    let languages = [
        "English",
        "Spanish",
        "French",
        "Chinese"
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
                                Text("Step 8")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("What are your language preferences?")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                Text("More than one option is possible.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.75))

                                VStack(spacing: 12) {
                                    ForEach(languages, id: \.self) { language in
                                        OnboardingCheckRow(
                                            title: language,
                                            isSelected: selectedLanguages.contains(language),
                                            action: {
                                                if selectedLanguages.contains(language) {
                                                    selectedLanguages.remove(language)
                                                } else {
                                                    selectedLanguages.insert(language)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.top, 2)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Other")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))

                                    TextField("Type your language", text: $otherLanguage)
                                        .textFieldStyle(OnboardingTextFieldStyle())
                                        .textInputAutocapitalization(.words)
                                        .disableAutocorrection(true)
                                }
                                .padding(.top, 6)
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
                        // Save language preferences
                        userDataManager.profile.languages = Array(selectedLanguages)
                        userDataManager.profile.otherLanguage = otherLanguage.isEmpty ? nil : otherLanguage

                        navigateToFinalTouch = true
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
            .navigationDestination(isPresented: $navigateToFinalTouch) {
                FinalTouchView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// Custom TextField Style for Language
struct LanguageTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "8B9A7E")) // Olive green background
            .cornerRadius(8)
            .foregroundColor(Color(hex: "5C3D2E"))
            .font(.system(size: 16, design: .rounded))
    }
}

#Preview {
    LanguagePreferencesView()
}

