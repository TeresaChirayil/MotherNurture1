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
                    Spacer()
                    
                    // Main Content
                    VStack(alignment: .leading, spacing: 30) {
                        // Question
                        Text("Would you like to start with a 1-on-1 buddy or a small parent circle?")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 40)
                        
                        // Options
                        VStack(spacing: 16) {
                            ForEach(ConnectionType.allCases, id: \.self) { option in
                                Button(action: {
                                    selectedOption = option
                                }) {
                                    Text(option.rawValue)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(selectedOption == option ? .white : Color(hex: "5C3D2E"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(selectedOption == option ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                        .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
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
                            // Save connection preference
                            userDataManager.profile.connectionPreference = selectedOption?.rawValue
                            
                            navigateToSpecialNeedsPreference = true
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

