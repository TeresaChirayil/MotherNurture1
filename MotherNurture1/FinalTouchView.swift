//
//  FinalTouchView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct FinalTouchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var description: String = ""
    @State private var navigateToChannels = false
    @State private var isSaving = false
    
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
                            // Instruction
                            Text("Last step - add a quick intro or photo so others can get to know you!")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 40)
                            
                            // Photo Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Photo:")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Button(action: {
                                    // Handle photo selection
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "8B9A7E"))
                                            .frame(width: 120, height: 120)
                                        
                                        Image(systemName: "mountain.2.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 50))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 40)
                            
                            // Short Description Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Short Description:")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                TextField("Tell us about yourself", text: $description, axis: .vertical)
                                    .textFieldStyle(FinalTouchTextFieldStyle())
                                    .lineLimit(5...10)
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
                        
                        // Done Button
                        Button(action: {
                            // Save final touch data
                            userDataManager.profile.shortDescription = description.isEmpty ? nil : description
                            
                            // Save to Firebase
                            isSaving = true
                            Task {
                                do {
                                    try await userDataManager.saveToFirebase()
                                    isSaving = false
                                    navigateToChannels = true
                                } catch {
                                    print("Error saving to Firebase: \(error)")
                                    isSaving = false
                                    // Still navigate even if save fails
                                    navigateToChannels = true
                                }
                            }
                        }) {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "8B9A7E"))
                                    .cornerRadius(12)
                            } else {
                                Text("Done!")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "8B9A7E"))
                                    .cornerRadius(12)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isSaving)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                .navigationDestination(isPresented: $navigateToChannels) {
                    ChannelsView()
                        .environmentObject(userDataManager)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
    }
}

// Custom TextField Style for Final Touch
struct FinalTouchTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .frame(minHeight: 120)
            .background(Color(hex: "8B9A7E")) // Olive green background
            .cornerRadius(12)
            .foregroundColor(Color(hex: "5C3D2E"))
            .font(.system(size: 16, design: .rounded))
    }
}

#Preview {
    FinalTouchView()
}

