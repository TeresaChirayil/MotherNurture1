//
//  MessagesTutorialView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct MessagesTutorialView: View {
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
                    // Graphic - Stack of Cards with Speech Bubbles
                    ZStack {
                        // Background cards (progressively darker shades)
                        ForEach(0..<2) { index in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "8B9A7E").opacity(0.3 - Double(index) * 0.1))
                                .frame(width: 200 - CGFloat(index) * 8, height: 260 - CGFloat(index) * 8)
                                .offset(x: CGFloat(index) * 12, y: CGFloat(index) * 12)
                        }
                        
                        // Top card (muted sage green with speech bubbles icon)
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "9BA897"))
                                .frame(width: 200, height: 260)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                            
                            // Two overlapping speech bubbles icon
                            ZStack {
                                // First speech bubble (behind)
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 45, weight: .light))
                                    .foregroundColor(.white.opacity(0.8))
                                    .offset(x: -8, y: 0)
                                
                                // Second speech bubble (front)
                                Image(systemName: "bubble.right.fill")
                                    .font(.system(size: 45, weight: .light))
                                    .foregroundColor(.white)
                                    .offset(x: 8, y: 0)
                            }
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                        .frame(height: 80)
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Heading
                        Text("Messages")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        // Description Text
                        Text("Contact other mothers 1-on-1 or participate in channels with moms with similar experiences.")
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
                        // First two active dots (dark green)
                        ForEach(0..<2) { _ in
                            Circle()
                                .fill(Color(hex: "8B9A7E"))
                                .frame(width: 10, height: 10)
                        }
                        
                        // Last three inactive dots (light gray)
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(Color(hex: "5C3D2E").opacity(0.2))
                                .frame(width: 10, height: 10)
                        }
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
                MatchmakingTutorialView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        MessagesTutorialView()
            .environmentObject(UserDataManager.shared)
    }
}

