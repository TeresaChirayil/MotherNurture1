//
//  ForumTutorialView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct ForumTutorialView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var navigateToSignUp = false
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "F8F5EE")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation - Previous Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            Text("Previous")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Main Content
                VStack(spacing: 40) {
                    // Graphic - Rounded Square with Book Icon
                    ZStack {
                        // Rounded square icon with muted sage green background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "9BA897"))
                            .frame(width: 200, height: 260)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        // Open book icon (white outline)
                        Image(systemName: "book")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                        .frame(height: 80)
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Heading
                        Text("Forum")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        // Description Text
                        Text("Post questions, interact with topic-based discussions, or filter for posts you need - anonymously.")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Bottom Navigation
                HStack {
                    // Pagination Dots
                    HStack(spacing: 8) {
                        // First four active dots (muted sage green - completed steps)
                        ForEach(0..<4) { _ in
                            Circle()
                                .fill(Color(hex: "8B9A7E"))
                                .frame(width: 10, height: 10)
                        }
                        
                        // Fifth dot (current step - light/off-white)
                        Circle()
                            .fill(Color(hex: "F8F5EE"))
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "5C3D2E").opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                    
                    // Next Button
                    Button(action: {
                        navigateToSignUp = true
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
            .navigationDestination(isPresented: $navigateToSignUp) {
                MapsTutorialView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ForumTutorialView()
            .environmentObject(UserDataManager.shared)
    }
}

