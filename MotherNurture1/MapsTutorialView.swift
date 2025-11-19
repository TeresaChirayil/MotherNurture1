//
//  MapsTutorialView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct MapsTutorialView: View {
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
                    // Graphic - Stack of Two Rounded Squares with Map Pin and Heart
                    ZStack {
                        // Bottom shape (darker green, angled slightly to bottom right)
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "8B9A7E").opacity(0.3))
                            .frame(width: 200 - 8, height: 260 - 8)
                            .offset(x: 12, y: 12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
                        
                        // Top shape (muted sage green, centered)
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "9BA897"))
                            .frame(width: 200, height: 260)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        // Map pin with heart inside
                        ZStack {
                            // Map pin outline (white)
                            Image(systemName: "mappin")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(.white)
                            
                            // Heart inside the map pin
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(.white)
                                .offset(y: -5)
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                        .frame(height: 80)
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Heading
                        Text("Maps")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        // Description Text
                        Text("Find places to meet up with your new friends on the map, or see events happening near you.")
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
                    // Pagination Dots (all five are dark green - indicating final step)
                    HStack(spacing: 8) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(Color(hex: "7C9473"))
                                .frame(width: 10, height: 10)
                                .opacity(index == 0 ? 1.0 : 0.9) // First dot slightly more prominent
                        }
                    }
                    
                    Spacer()
                    
                    // Sign Up Button
                    Button(action: {
                        navigateToSignUp = true
                    }) {
                        Text("Sign up!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "EADDCB"))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignUpView()
                    .environmentObject(userDataManager)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        MapsTutorialView()
            .environmentObject(UserDataManager.shared)
    }
}

