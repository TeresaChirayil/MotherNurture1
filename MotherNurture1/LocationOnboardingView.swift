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
    @State private var town: String = ""
    @State private var navigateToParentingStage = false
    
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
                    Text("To get started,\nWhere are you located?")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    // Input Fields
                    VStack(alignment: .leading, spacing: 20) {
                        // Zipcode Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Zipcode:")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            TextField("Enter zipcode", text: $zipcode)
                                .textFieldStyle(LocationTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Town Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Town:")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            TextField("Enter town", text: $town)
                                .textFieldStyle(LocationTextFieldStyle())
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
                        // Save location data
                        userDataManager.profile.zipcode = zipcode.isEmpty ? nil : zipcode
                        userDataManager.profile.town = town.isEmpty ? nil : town
                        
                        navigateToParentingStage = true
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

