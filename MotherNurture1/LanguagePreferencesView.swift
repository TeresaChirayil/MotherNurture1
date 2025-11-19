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
                    Spacer()
                    
                    ScrollView {
                        // Main Content
                        VStack(alignment: .leading, spacing: 30) {
                            // Question
                            Text("What are your language preferences?")
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
                            
                            // Language Options
                            VStack(spacing: 16) {
                                ForEach(languages, id: \.self) { language in
                                    Button(action: {
                                        if selectedLanguages.contains(language) {
                                            selectedLanguages.remove(language)
                                        } else {
                                            selectedLanguages.insert(language)
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            if selectedLanguages.contains(language) {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                            } else {
                                                Spacer()
                                                    .frame(width: 14)
                                            }
                                            
                                            Text(language)
                                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                                .foregroundColor(selectedLanguages.contains(language) ? .white : Color(hex: "5C3D2E"))
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(selectedLanguages.contains(language) ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            // Other Language Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Other: please type in your preference.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                
                                TextField("Type your language", text: $otherLanguage)
                                    .textFieldStyle(LanguageTextFieldStyle())
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
                            // Save language preferences
                            userDataManager.profile.languages = Array(selectedLanguages)
                            userDataManager.profile.otherLanguage = otherLanguage.isEmpty ? nil : otherLanguage
                            
                            navigateToFinalTouch = true
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

