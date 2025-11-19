//
//  MatchmakingTutorialView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct MatchmakingTutorialView: View {
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
                    // Graphic - Stack of Cards with Link Icon
                    ZStack {
                        // Background cards (progressively darker shades, offset to right and down)
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "8B9A7E").opacity(0.3 - Double(index) * 0.08))
                                .frame(width: 200 - CGFloat(index) * 8, height: 260 - CGFloat(index) * 8)
                                .offset(
                                    x: CGFloat(index) * 12,
                                    y: CGFloat(index) * 12
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
                        }
                        
                        // Top card (muted sage green with link icon)
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "9BA897"))
                                .frame(width: 200, height: 260)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 3, y: 3)
                            
                            // Chain link icon (two interlocking links)
                            Image(systemName: "link")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                        .frame(height: 80)
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Heading
                        Text("Matchmaking")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        // Description Text
                        Text("Find compatible mothers who share the same interests or live nearby. Swipe right to see if you're a match!")
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
                        // First three active dots (dark green)
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(Color(hex: "8B9A7E"))
                                .frame(width: 10, height: 10)
                        }
                        
                        // Last two inactive dots (light gray)
                        ForEach(0..<2) { _ in
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
                ForumTutorialView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        MatchmakingTutorialView()
            .environmentObject(UserDataManager.shared)
    }
}

